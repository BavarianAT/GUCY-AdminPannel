import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/comment_data.dart';
import '../models/post_data.dart';
import '../models/user_data.dart';

class PostsProvider with ChangeNotifier {
  late List<PostData> _posts;

  PostsProvider() {
    // Initialize the posts list or any other setup
    _posts = [];
    _loadPosts();
  }

  List<PostData> get posts => _posts;

  void _loadPosts() {
    FirebaseFirestore.instance.collection('posts').snapshots().listen(
      (QuerySnapshot snapshot) {
        _posts = snapshot.docs.map((doc) {
          Map<String, dynamic> postData = doc.data() as Map<String, dynamic>;
          PostData post = PostData.fromJson(postData);
          post.id = doc.id;
          return post;
        }).toList();
        notifyListeners();
      },
      onError: (error) {
        // Handle errors if needed
        print('Error fetching posts: $error');
      },
    );
  }

  PostData getPostById(String postId) {
    return _posts.firstWhere(
      (post) => post.id == postId,
    );
  }

  Future<void> addLikeToPost(String postId, UserData currentUser) async {
    try {
      // Update the likes list for the post in Firestore
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayUnion([currentUser.uid]),
      });

      // Notify listeners that the posts list has changed
      notifyListeners();
    } catch (e) {
      // Handle errors if needed
      print('Error adding like to post: $e');
    }
  }

  Future<void> removeLikeFromPost(String postId, UserData currentUser) async {
    try {
      // Update the likes list for the post in Firestore
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayRemove([currentUser.uid]),
      });

      // Notify listeners that the posts list has changed
      notifyListeners();
    } catch (e) {
      // Handle errors if needed
      print('Error removing like from post: $e');
    }
  }

  Future<void> addDislikeToPost(String postId, UserData currentUser) async {
    try {
      // Update the dislikes list for the post in Firestore
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'dislikes': FieldValue.arrayUnion([currentUser.uid]),
      });

      // Notify listeners that the posts list has changed
      notifyListeners();
    } catch (e) {
      // Handle errors if needed
      print('Error adding dislike to post: $e');
    }
  }

  Future<void> removeDislikeFromPost(
      String postId, UserData currentUser) async {
    try {
      // Update the dislikes list for the post in Firestore
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'dislikes': FieldValue.arrayRemove([currentUser.uid]),
      });

      // Notify listeners that the posts list has changed
      notifyListeners();
    } catch (e) {
      // Handle errors if needed
      print('Error removing dislike from post: $e');
    }
  }

  Future<void> loadCommentsForPost(String postId) async {
    try {
      // Fetch comments for the post from Firestore
      int postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        QuerySnapshot<Map<String, dynamic>> commentsSnapshot =
            await FirebaseFirestore.instance
                .collection('posts')
                .doc(postId)
                .collection('comments')
                .get();

        // Map comments data to CommentData objects
        List<CommentData> comments = commentsSnapshot.docs.map((commentDoc) {
          CommentData comment = CommentData.fromJson(commentDoc.data());
          comment.id = commentDoc.id;
          return comment;
        }).toList();

        // Populate the comments for the post
        _posts[postIndex].comments = comments;

        // Notify listeners that the posts list has changed
        notifyListeners();
      }
    } catch (e) {
      // Handle errors if needed
      print('Error loading comments for post: $e');
    }
  }

  Future<void> addCommentToPost(String postId, CommentData comment) async {
    try {
      // Add the comment to Firestore
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add({
        'body': comment.body,
        'user': comment.user.toJson(),
        'createdAt': comment.createdAt,
        'likes': comment.likes,
        'dislikes': comment.dislikes,
      });

      // Notify listeners that the posts list has changed
      notifyListeners();
    } catch (e) {
      // Handle errors if needed
      print('Error adding comment to post: $e');
    }
  }

  Future<DocumentReference> addPost(PostData post) {
    Map<String, dynamic> postJson = post.toJson();
    postJson.removeWhere((key, value) => key == "comments");
    return FirebaseFirestore.instance.collection('posts').add(postJson);
  }
}
