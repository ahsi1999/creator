import 'dart:developer';
import 'dart:io' show File;
import 'package:creator/app/data/creator_model.dart';
import 'package:creator/app/data/media_item.dart';
import 'package:creator/app/modules/creators/controllers/creator_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class AddCreatorView extends StatefulWidget {
  const AddCreatorView({super.key});

  @override
  State<AddCreatorView> createState() => _AddCreatorViewState();
}

class _AddCreatorViewState extends State<AddCreatorView> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _designation = TextEditingController();
  final _about = TextEditingController();
  final _price = TextEditingController();

  final List<MediaItem> _selectedMedia = [];

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.media,
        withData: true, // ensures bytes are loaded for web
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedMedia.clear();
          for (final file in result.files) {
            _selectedMedia.add(
              MediaItem(
                name: file.name,
                bytes: file.bytes,
                // 🧩 Only use path if NOT on Web
                path: kIsWeb ? null : file.path,
              ),
            );
          }
        });
      }
    } catch (e) {
      debugPrint('File picking error: $e');
      Get.snackbar(
        'Error',
        'Failed to pick files. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreatorController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Add New Creator'),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Creator Information',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Please enter a name'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _designation,
                        decoration: const InputDecoration(
                          labelText: 'Designation',
                          prefixIcon: Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _about,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'About Creator',
                          prefixIcon: Icon(Icons.info_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Price
                      TextFormField(
                        controller: _price,
                        decoration: const InputDecoration(
                          labelText: 'Price (₹)',
                          prefixIcon: Icon(Icons.currency_rupee),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Enter price';
                          }
                          final val = double.tryParse(v);
                          if (val == null || val < 0) {
                            return 'Enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'Upload Images / Videos',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),

                      GestureDetector(
                        onTap: _pickFiles,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: _selectedMedia.isEmpty ? 160 : 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 1.5,
                            ),
                            color: Colors.grey[100],
                          ),
                          child: _selectedMedia.isEmpty
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                        Icons.add_photo_alternate_outlined,
                                        size: 48,
                                        color: Colors.grey),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap to select files',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GridView.builder(
                                    itemCount: _selectedMedia.length,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 8,
                                    ),
                                    itemBuilder: (context, index) {
                                      final media = _selectedMedia[index];
                                      final isVideo = media.name
                                          .toLowerCase()
                                          .endsWith('.mp4');

                                      Widget content;
                                      if (isVideo) {
                                        content = const Center(
                                          child: Icon(Icons.videocam,
                                              color: Colors.grey, size: 40),
                                        );
                                      } else {
                                        if (kIsWeb && media.bytes != null) {
                                          content = Image.memory(
                                            media.bytes!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          );
                                        } else if (!kIsWeb &&
                                            media.path != null) {
                                          content = Image.file(
                                            File(media.path!),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          );
                                        } else {
                                          content = const Icon(Icons.image);
                                        }
                                      }

                                      return Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: content,
                                          ),
                                          Positioned(
                                            top: -8,
                                            right: -8,
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _selectedMedia
                                                      .removeAt(index);
                                                });
                                              },
                                              child: const CircleAvatar(
                                                radius: 10,
                                                backgroundColor: Colors.red,
                                                child: Icon(Icons.close,
                                                    size: 12,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.save_alt_rounded),
                            label: const Text(
                              'Save Creator',
                              style: TextStyle(fontSize: 16),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (_selectedMedia.isEmpty) {
                                  Get.snackbar('Error',
                                      'Please select at least one media file');
                                  return;
                                }
                                final creator = Creator(
                                  id: const Uuid().v4(),
                                  name: _name.text.trim(),
                                  designation: _designation.text.trim(),
                                  about: _about.text.trim(),
                                  price: double.tryParse(_price.text) ?? 0.0,
                                  media: [],
                                );

                                try {
                                  log("saving");
                                  await controller.addCreator(
                                      creator, _selectedMedia);
                                } catch (e) {
                                  print(
                                      'Error adding creator: $e'); // for debug
                                  Get.snackbar('Error', e.toString());
                                }
                              }
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
