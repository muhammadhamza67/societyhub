import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../services/api_service.dart';

class RateWorkerScreen extends StatefulWidget {
  final String workerId;
  final String residentId;
  final String requestId;

  const RateWorkerScreen({
    super.key,
    required this.workerId,
    required this.residentId,
    required this.requestId,
  });

  @override
  State<RateWorkerScreen> createState() => _RateWorkerScreenState();
}

class _RateWorkerScreenState extends State<RateWorkerScreen> {
  int rating = 3;
  bool loading = false;
  final TextEditingController commentController = TextEditingController();

  void submit() async {
    setState(() => loading = true);

    final success = await ApiService.submitWorkerRating(
  workerId: widget.workerId,
  residentId: widget.residentId,
  requestId: widget.requestId,
  rating: rating,
  comment: commentController.text,
);


    setState(() => loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⭐ Rating submitted successfully")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to submit rating")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rate Worker")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("How was the service?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            RatingBar.builder(
              initialRating: rating.toDouble(),
              minRating: 1,
              allowHalfRating: false,
              itemCount: 5,
              itemBuilder: (context, _) =>
                  const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (value) {
                rating = value.toInt();
              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller: commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Write a comment (optional)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : submit,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit Rating"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
