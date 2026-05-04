import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zero_type/core/constants/app_constants.dart';
import 'package:zero_type/features/model_config/domain/entities/ai_provider.dart';
import 'package:zero_type/features/model_config/domain/repositories/model_config_repository.dart';

class ModelConfigRepositoryImpl implements ModelConfigRepository {
  ModelConfigRepositoryImpl({
    required SharedPreferences prefs,
  }) : _prefs = prefs;

  final SharedPreferences _prefs;

  @override
  Future<ProvidersConfig> loadProvidersConfig() async {
    final jsonString =
        await rootBundle.loadString('assets/config/providers.json');
    final json = jsonDecode(jsonString) as Map<String, dynamic>;

    AiProvider parseProvider(Map<String, dynamic> p) => AiProvider(
          id: p['id'] as String,
          name: p['name'] as String,
          models: (p['models'] as List)
              .map(
                (m) => AiModel(
                  id: m['id'] as String,
                  name: m['name'] as String,
                ),
              )
              .toList(),
        );

    return ProvidersConfig(
      speechRecognition: (json['speechRecognition'] as List)
          .map((p) => parseProvider(p as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<String?> getSelectedSpeechProviderId() async =>
      _prefs.getString(AppConstants.selectedSpeechProviderKey);

  @override
  Future<void> saveSelectedSpeechProviderId(String providerId) async =>
      _prefs.setString(AppConstants.selectedSpeechProviderKey, providerId);

  @override
  Future<String?> getSelectedSpeechModelId(String providerId) async =>
      _prefs.getString('${AppConstants.selectedSpeechModelKey}_$providerId');

  @override
  Future<void> saveSelectedSpeechModelId(String providerId, String modelId) async =>
      _prefs.setString('${AppConstants.selectedSpeechModelKey}_$providerId', modelId);

  @override
  Future<String?> getSpeechApiKey(String providerId) async =>
      _prefs.getString('api_key_speech_$providerId');

  @override
  Future<void> saveSpeechApiKey(String providerId, String apiKey) async =>
      _prefs.setString('api_key_speech_$providerId', apiKey);

  @override
  Future<String?> getCustomEndpoint(String providerId) async =>
      _prefs.getString('custom_endpoint_$providerId');

  @override
  Future<void> saveCustomEndpoint(String providerId, String endpoint) async =>
      _prefs.setString('custom_endpoint_$providerId', endpoint);

  @override
  Future<List<AiModel>> getCachedModels(String providerId) async {
    final raw = _prefs.getString('cached_models_$providerId');
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((m) => AiModel(
                id: (m as Map<String, dynamic>)['id'] as String,
                name: m['name'] as String,
              ))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> saveCachedModels(String providerId, List<AiModel> models) async {
    final raw = jsonEncode(
      models.map((m) => {'id': m.id, 'name': m.name}).toList(),
    );
    await _prefs.setString('cached_models_$providerId', raw);
  }

  // ── Refinement ────────────────────────────────────────────────────────────

  @override
  Future<String?> getSelectedRefinementProviderId() async =>
      _prefs.getString(AppConstants.selectedRefinementProviderKey);

  @override
  Future<void> saveSelectedRefinementProviderId(String providerId) async =>
      _prefs.setString(AppConstants.selectedRefinementProviderKey, providerId);

  @override
  Future<String?> getSelectedRefinementModelId(String providerId) async =>
      _prefs
          .getString('${AppConstants.selectedRefinementModelKey}_$providerId');

  @override
  Future<void> saveSelectedRefinementModelId(
          String providerId, String modelId) async =>
      _prefs.setString(
          '${AppConstants.selectedRefinementModelKey}_$providerId', modelId);

  @override
  Future<String?> getRefinementApiKey(String providerId) async =>
      _prefs.getString('api_key_refinement_$providerId');

  @override
  Future<void> saveRefinementApiKey(String providerId, String apiKey) async =>
      _prefs.setString('api_key_refinement_$providerId', apiKey);

  @override
  Future<String?> getRefinementCustomEndpoint(String providerId) async =>
      _prefs.getString('custom_endpoint_refinement_$providerId');

  @override
  Future<void> saveRefinementCustomEndpoint(
          String providerId, String endpoint) async =>
      _prefs.setString('custom_endpoint_refinement_$providerId', endpoint);

  @override
  Future<List<AiModel>> getRefinementCachedModels(String providerId) async {
    final raw = _prefs.getString('cached_models_refinement_$providerId');
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((m) => AiModel(
                id: (m as Map<String, dynamic>)['id'] as String,
                name: m['name'] as String,
              ))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> saveRefinementCachedModels(
      String providerId, List<AiModel> models) async {
    final raw = jsonEncode(
      models.map((m) => {'id': m.id, 'name': m.name}).toList(),
    );
    await _prefs.setString('cached_models_refinement_$providerId', raw);
  }
}
