import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'dtos/document/document_dtos.dart';
import 'dtos/exception/exception_dtos.dart';

part 'document_client.g.dart';

/// Retrofit client for document upload and processing API
/// Note: Retrofit requires static endpoints, so configuration is limited to baseUrl and timeouts
@RestApi()
abstract class DocumentClient {
  factory DocumentClient(Dio dio, {String baseUrl}) = _DocumentClient;

  /// Upload a document for processing
  /// POST /api/v1/documents/process
  @POST('/api/v1/documents/process')
  @MultiPart()
  Future<DocumentUploadResponse> uploadDocument(
    @Part(name: 'file') File file,
    @Part(name: 'documentType') String documentType,
    @Part(name: 'portfolioId') String portfolioId,
    @Part(name: 'userId') String userId, {
    @Part(name: 'description') String? description,
  });
}