import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:zero_type/features/model_config/domain/entities/ai_provider.dart';

abstract class ModelConfigRepository {
  Future<ProvidersConfig> loadProvidersConfig();

  Future<String?> getSelectedSpeechProviderId();
  Future<void> saveSelectedSpeechProviderId(String providerId);

  Future<String?> getSelectedSpeechModelId(String providerId);
  Future<void> saveSelectedSpeechModelId(String providerId, String modelId);

  Future<String?> getSpeechApiKey(String providerId);
  Future<void> saveSpeechApiKey(String providerId, String apiKey);

  Future<String?> getCustomEndpoint(String providerId);
  Future<void> saveCustomEndpoint(String providerId, String endpoint);

  /// Cached model list fetched from a dynamic provider's /v1/models endpoint.
  /// Empty list when nothing has been fetched yet.
  Future<List<AiModel>> getCachedModels(String providerId);
  Future<void> saveCachedModels(String providerId, List<AiModel> models);

  // ── Refinement (text-polishing) configuration ─────────────────────────────
  // Mirrors the speech-recognition setters above but in a separate
  // namespace so the user can use one provider/model for transcription and
  // a completely different one for post-processing.

  Future<String?> getSelectedRefinementProviderId();
  Future<void> saveSelectedRefinementProviderId(String providerId);

  Future<String?> getSelectedRefinementModelId(String providerId);
  Future<void> saveSelectedRefinementModelId(String providerId, String modelId);

  Future<String?> getRefinementApiKey(String providerId);
  Future<void> saveRefinementApiKey(String providerId, String apiKey);

  Future<String?> getRefinementCustomEndpoint(String providerId);
  Future<void> saveRefinementCustomEndpoint(String providerId, String endpoint);

  Future<List<AiModel>> getRefinementCachedModels(String providerId);
  Future<void> saveRefinementCachedModels(
      String providerId, List<AiModel> models);
}
