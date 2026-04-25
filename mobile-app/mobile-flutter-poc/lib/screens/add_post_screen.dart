import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../services/post_service.dart';
import '../utils/post_utils.dart';
import '../utils/date_utils.dart' as app_date_utils;
import '../widgets/bottom_navigation.dart';

class AddPostScreen extends StatefulWidget {
  final String? postId;
  final DateTime? initialDate;
  final String? initialNote;
  final String? initialPhotoUrl;

  const AddPostScreen({
    super.key,
    this.postId,
    this.initialDate,
    this.initialNote,
    this.initialPhotoUrl,
  });

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  final PostService _postService = PostService();
  
  DateTime _selectedDate = DateTime.now();
  File? _selectedImage;
  String? _imageUrl;
  bool _loading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.postId != null;
    if (widget.initialDate != null) {
      _selectedDate = widget.initialDate!;
    }
    if (widget.initialNote != null) {
      _noteController.text = widget.initialNote!;
    }
    if (widget.initialPhotoUrl != null) {
      _imageUrl = widget.initialPhotoUrl;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _imageUrl = null; // Clear existing URL when new image is selected
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _imageUrl = null;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_noteController.text.trim().isEmpty && _selectedImage == null && _imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a note or photo')),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user == null) return;

      String? photoUrl = _imageUrl;

      // Upload new image if selected
      if (_selectedImage != null) {
        photoUrl = await PostUtils.uploadImage(_selectedImage!);
      }

      final note = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();

      if (_isEditMode && widget.postId != null) {
        // Update existing post
        await _postService.updatePost(
          authProvider.user!.email!,
          widget.postId!,
          _selectedDate,
          note,
          photoUrl,
          widget.initialPhotoUrl,
        );
      } else {
        // Create new post
        await _postService.createPost(
          authProvider.user!.email!,
          note,
          photoUrl,
          _selectedDate,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Good Thought' : 'Add Good Thought'),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(currentScreen: CurrentScreen.add),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Date Picker
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Select Date'),
                subtitle: Text(
                      app_date_utils.AppDateUtils.formatDate(_selectedDate, format: 'dd MMMM yyyy'),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _selectDate,
              ),
            ),
            const SizedBox(height: 16),

            // Note Input
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Your Good Thought',
                hintText: 'Type your good thing here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  if (_selectedImage == null && _imageUrl == null) {
                    return 'Please add a note or photo';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Image Preview
            if (_selectedImage != null || _imageUrl != null)
              Card(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _selectedImage != null
                          ? Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                              height: 200,
                              width: double.infinity,
                            )
                          : Image.network(
                              _imageUrl!,
                              fit: BoxFit.cover,
                              height: 200,
                              width: double.infinity,
                            ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: _removeImage,
                      ),
                    ),
                  ],
                ),
              ),

            if (_selectedImage != null || _imageUrl != null) const SizedBox(height: 16),

            // Image Upload Options
            const Text(
              'Add Photo (Optional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: InkWell(
                      onTap: () => _pickImage(ImageSource.gallery),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.photo_library,
                              size: 48,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(height: 8),
                            const Text('Gallery'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: InkWell(
                      onTap: () => _pickImage(ImageSource.camera),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 48,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(height: 8),
                            const Text('Camera'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _loading
                      ? (_isEditMode ? 'Updating...' : 'Posting...')
                      : (_isEditMode ? 'Update Good Thought' : 'Post Good Thought'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

