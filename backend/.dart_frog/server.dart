// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, implicit_dynamic_list_literal

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';


import '../routes/index.dart' as index;
import '../routes/vendors/register.dart' as vendors_register;
import '../routes/vendors/index.dart' as vendors_index;
import '../routes/todos/index.dart' as todos_index;
import '../routes/guests/index.dart' as guests_index;
import '../routes/guests/[id].dart' as guests_$id;
import '../routes/dashboard/stats.dart' as dashboard_stats;
import '../routes/budget/index.dart' as budget_index;
import '../routes/auth/register.dart' as auth_register;
import '../routes/auth/login.dart' as auth_login;
import '../routes/ai/chat.dart' as ai_chat;

import '../routes/_middleware.dart' as middleware;
import '../routes/todos/_middleware.dart' as todos_middleware;
import '../routes/guests/_middleware.dart' as guests_middleware;
import '../routes/dashboard/_middleware.dart' as dashboard_middleware;
import '../routes/budget/_middleware.dart' as budget_middleware;

void main() async {
  final address = InternetAddress.tryParse('') ?? InternetAddress.anyIPv6;
  final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;
  hotReload(() => createServer(address, port));
}

Future<HttpServer> createServer(InternetAddress address, int port) {
  final handler = Cascade().add(buildRootHandler()).handler;
  return serve(handler, address, port);
}

Handler buildRootHandler() {
  final pipeline = const Pipeline().addMiddleware(middleware.middleware);
  final router = Router()
    ..mount('/', (context) => buildHandler()(context))
    ..mount('/vendors', (context) => buildVendorsHandler()(context))
    ..mount('/todos', (context) => buildTodosHandler()(context))
    ..mount('/guests', (context) => buildGuestsHandler()(context))
    ..mount('/dashboard', (context) => buildDashboardHandler()(context))
    ..mount('/budget', (context) => buildBudgetHandler()(context))
    ..mount('/auth', (context) => buildAuthHandler()(context))
    ..mount('/ai', (context) => buildAiHandler()(context));
  return pipeline.addHandler(router);
}

Handler buildHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildVendorsHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/register', (context) => vendors_register.onRequest(context,))..all('/', (context) => vendors_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildTodosHandler() {
  final pipeline = const Pipeline().addMiddleware(todos_middleware.middleware);
  final router = Router()
    ..all('/', (context) => todos_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildGuestsHandler() {
  final pipeline = const Pipeline().addMiddleware(guests_middleware.middleware);
  final router = Router()
    ..all('/<id>', (context,id,) => guests_$id.onRequest(context,id,))..all('/', (context) => guests_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildDashboardHandler() {
  final pipeline = const Pipeline().addMiddleware(dashboard_middleware.middleware);
  final router = Router()
    ..all('/stats', (context) => dashboard_stats.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildBudgetHandler() {
  final pipeline = const Pipeline().addMiddleware(budget_middleware.middleware);
  final router = Router()
    ..all('/', (context) => budget_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildAuthHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/login', (context) => auth_login.onRequest(context,))..all('/register', (context) => auth_register.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildAiHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/chat', (context) => ai_chat.onRequest(context,));
  return pipeline.addHandler(router);
}

