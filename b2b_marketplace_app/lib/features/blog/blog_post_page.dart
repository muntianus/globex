
import 'package:flutter/material.dart';

class BlogPostPage extends StatelessWidget {
  final String slug;
  const BlogPostPage({super.key, required this.slug});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Blog Post: $slug')), body: Center(child: Text('Blog Post Page for $slug')));
  }
}
