import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final body = await context.request.json() as Map<String, dynamic>;
  final prompt = body['prompt'] as String?;

  if (prompt == null || prompt.isEmpty) {
    return Response(
        statusCode: HttpStatus.badRequest, body: 'Prompt is required');
  }

  final apiKey = Platform.environment['GEMINI_API_KEY'];
  if (apiKey == null) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'AI Assistant is not configured (missing API Key)',
    );
  }

  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

  try {
    final content = [
      Content.text(
          'You are a premium wedding planning assistant. Help the couple with their questions elegantly. Prompt: $prompt')
    ];
    final response = await model.generateContent(content);
    return Response.json(body: {'response': response.text});
  } catch (e) {
    return Response(
        statusCode: HttpStatus.internalServerError, body: 'AI Error: $e');
  }
}
