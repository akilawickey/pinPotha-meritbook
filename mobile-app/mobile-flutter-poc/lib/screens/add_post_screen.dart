import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/posts_provider.dart';
import '../providers/navigation_provider.dart';
import '../services/post_draft.dart';
import '../utils/date_utils.dart';

class AddPostScreen extends StatefulWidget {
  final DateTime? initialDate;
  final bool embedded;
  final ValueChanged<DateTime>? onSaved;
  const AddPostScreen(
      {super.key, this.initialDate, this.embedded = false, this.onSaved});
  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _note = TextEditingController();
  late PostDraft _draft;
  DateTime? _date;
  DateTime? _lastNavigationDate;
  File? _image;
  bool _initialized = false;
  bool _dirty = false;
  bool _allowPop = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _draft = PostDraft(context.read<PostsProvider>())..addListener(_changed);
      _date =
          widget.initialDate ?? context.read<NavigationProvider>().selectedDate;
      _initialized = true;
    }
    final selected = context.watch<NavigationProvider>().selectedDate;
    if (widget.embedded &&
        !_dirty &&
        !_draft.frozen &&
        selected != _lastNavigationDate) {
      _date = selected;
    }
    _lastNavigationDate = selected;
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _draft.removeListener(_changed);
    _draft.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    if (_draft.frozen || _draft.busy) return;
    try {
      final image = await ImagePicker().pickImage(
          source: source, maxWidth: 1920, maxHeight: 1080, imageQuality: 90);
      if (image != null && mounted) {
        setState(() {
          _image = File(image.path);
          _dirty = true;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Could not open camera or photos. Check permission in device settings.')));
      }
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
        context: context,
        initialDate: _date!,
        firstDate: DateTime(1),
        lastDate: DateTime(9999, 12, 31));
    if (date != null && mounted) {
      setState(() {
        _date = date;
        _dirty = true;
      });
    }
  }

  Future<bool> _discard() async {
    if (_draft.busy) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Save is still pending. Keep this draft open until it finishes.')));
      return false;
    }
    if (!_dirty && !_draft.frozen) return true;
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Discard draft?'),
                content:
                    const Text('Your unsaved good thought will be discarded.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Keep draft')),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Discard')),
                ]));
    if (confirmed != true) return false;
    await _draft.discard();
    if (mounted) {
      setState(() {
        _note.clear();
        _image = null;
        _dirty = false;
      });
    }
    return true;
  }

  Future<void> _submit() async {
    await _draft.submit(note: _note.text, date: _date!, image: _image);
    if (!mounted || !_draft.saved) return;
    final savedDate = _date!;
    context.read<NavigationProvider>().showSavedDate(savedDate);
    setState(() {
      _dirty = false;
      _allowPop = !widget.embedded;
    });
    if (widget.embedded) {
      _draft.removeListener(_changed);
      _draft.dispose();
      _draft = PostDraft(context.read<PostsProvider>())..addListener(_changed);
      _note.clear();
      _image = null;
      widget.onSaved?.call(savedDate);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Good thought saved.')));
    } else {
      // Allow PopScope to rebuild before completing the route.
      await WidgetsBinding.instance.endOfFrame;
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabled = _draft.frozen || _draft.busy;
    final page = Scaffold(
        appBar: AppBar(title: const Text('Add Good Thought'), actions: [
          if (_dirty || _draft.frozen)
            TextButton(
                onPressed: _draft.busy ? null : _discard,
                child: const Text('Discard')),
        ]),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Selected date'),
              subtitle:
                  Text(AppDateUtils.formatDate(_date!, format: 'dd MMMM yyyy')),
              onTap: disabled ? null : _selectDate),
          const SizedBox(height: 16),
          TextField(
              controller: _note,
              enabled: !disabled,
              maxLines: 6,
              onChanged: (_) => setState(() => _dirty = true),
              decoration: const InputDecoration(
                  labelText: 'Your Good Thought',
                  hintText: 'Type your good thing here…',
                  border: OutlineInputBorder())),
          const SizedBox(height: 16),
          if (_image != null)
            Stack(children: [
              Image.file(_image!,
                  height: 220, width: double.infinity, fit: BoxFit.cover),
              Positioned(
                  right: 4,
                  top: 4,
                  child: IconButton(
                      tooltip: 'Remove photo',
                      onPressed: disabled
                          ? null
                          : () => setState(() {
                                _image = null;
                                _dirty = true;
                              }),
                      icon: const Icon(Icons.close))),
            ]),
          Row(children: [
            Expanded(
                child: OutlinedButton.icon(
                    onPressed:
                        disabled ? null : () => _pick(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'))),
            const SizedBox(width: 12),
            Expanded(
                child: OutlinedButton.icon(
                    onPressed:
                        disabled ? null : () => _pick(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'))),
          ]),
          const SizedBox(height: 24),
          if (_draft.error != null)
            Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                    _draft.error is ArgumentError
                        ? 'Please add a note or photo.'
                        : 'Could not save. Your draft is kept. Check your connection and retry.',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error))),
          if (_draft.waitingForServer)
            const Text(
                'Still waiting for the server. Keep the app open; this save will not create a duplicate.'),
          if (_draft.frozen && !_draft.busy)
            const Text(
                'Retry sends the same draft. To make changes, discard it first.'),
          FilledButton(
              onPressed: _draft.busy ? null : _submit,
              child: Text(_draft.busy
                  ? 'Saving…'
                  : _draft.frozen
                      ? 'Retry save'
                      : 'Post Good Thought')),
          if (_draft.busy)
            const Padding(
                padding: EdgeInsets.all(16), child: LinearProgressIndicator()),
          const Text(
              'Connect to the internet to save. Drafts are kept while this screen remains open; closing the app discards unsaved drafts.'),
        ]));
    return PopScope(
        canPop: _allowPop || (!_dirty && !_draft.frozen && !_draft.busy),
        onPopInvokedWithResult: (popped, result) async {
          if (popped) return;
          final navigator = Navigator.of(context);
          if (await _discard() && mounted) {
            setState(() => _allowPop = true);
            await WidgetsBinding.instance.endOfFrame;
            if (mounted) navigator.pop();
          }
        },
        child: page);
  }
}
