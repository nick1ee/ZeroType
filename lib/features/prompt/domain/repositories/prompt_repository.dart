abstract class PromptRepository {
  Future<String> getSpeechPrompt();
  Future<String> saveSpeechPrompt(String prompt);
  Future<String> getDefaultSpeechPrompt();
  Future<String> resetSpeechPrompt();

  Future<String> getRefinementPrompt();
  Future<String> saveRefinementPrompt(String prompt);
  Future<String> getDefaultRefinementPrompt();
  Future<String> resetRefinementPrompt();
}
