import 'package:chat_bot/providers/message_provider.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class GeminiService {
  
   Future<String?> generateMessage(String prompt,MessageProvider messageProvider) async {
    final apikey = dotenv.env['API_KEY'] ?? "";
    try {
      
      messageProvider.setLoading(true);

      final model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: apikey,
      );

      String conversationContext = messageProvider.getConversationContext();

      final fullPrompt = "$conversationContext\nUser: $prompt";

      final response = await model.generateContent([Content.text(fullPrompt)]);

      messageProvider.setLoading(false);

      if (response.text!= null) {
        final chatMessage = ChatMessage(
          message: response.text!,
          user: "Gemini", 
          time: DateTime.now(),
          );
          messageProvider.storeMessage(chatMessage);
      }
      else{
        messageProvider.storeMessage(ChatMessage(
          message: "AI did not respond.",
          user: "AI",
          time: DateTime.now(),
        ));
        return null;
      }
    } catch (e) {
      messageProvider.storeMessage(ChatMessage(
        message: "Error: Unable to fetch AI response.",
        user: "System",
        time: DateTime.now(),
      ));
      return "Error $e";
    }
    finally {
      messageProvider.setLoading(false);
    }
    return null;
  }
}
