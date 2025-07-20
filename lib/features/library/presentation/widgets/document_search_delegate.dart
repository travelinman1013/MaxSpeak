import 'package:flutter/material.dart';
import '../../domain/entities/document.dart';

class DocumentSearchDelegate extends SearchDelegate<String> {
  final List<Document> documents;
  
  DocumentSearchDelegate({required this.documents});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredDocuments = documents.where((doc) =>
        doc.title.toLowerCase().contains(query.toLowerCase()) ||
        doc.originalFileName.toLowerCase().contains(query.toLowerCase())).toList();

    if (filteredDocuments.isEmpty) {
      return const Center(
        child: Text('No documents found'),
      );
    }

    return ListView.builder(
      itemCount: filteredDocuments.length,
      itemBuilder: (context, index) {
        final document = filteredDocuments[index];
        return ListTile(
          title: Text(document.title),
          subtitle: Text(document.originalFileName),
          leading: const Icon(Icons.picture_as_pdf),
          onTap: () {
            close(context, document.id);
            Navigator.pushNamed(
              context,
              '/reader',
              arguments: document.id,
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Start typing to search documents'),
      );
    }

    final suggestions = documents.where((doc) =>
        doc.title.toLowerCase().contains(query.toLowerCase())).take(5).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final document = suggestions[index];
        return ListTile(
          title: Text(document.title),
          subtitle: Text(document.originalFileName),
          leading: const Icon(Icons.picture_as_pdf),
          onTap: () {
            query = document.title;
            showResults(context);
          },
        );
      },
    );
  }
}
