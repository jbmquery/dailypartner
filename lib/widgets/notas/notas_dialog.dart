//lib/widgets/notas/notas_dialog.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotasDialog extends StatefulWidget {
  final DocumentSnapshot? noteDoc;

  const NotasDialog({super.key, this.noteDoc});

  @override
  State<NotasDialog> createState() => _NotasDialogState();
}

class _NotasDialogState extends State<NotasDialog> {
  final user = FirebaseAuth.instance.currentUser!;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  bool isLoading = false;

  bool get isEditing => widget.noteDoc != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      final data = widget.noteDoc!.data() as Map<String, dynamic>? ?? {};

      titleController.text = data["titulo"] ?? "";
      bodyController.text = data["cuerpo"] ?? "";
    }
  }

  String currentInfo() {
    final now = DateTime.now();

    final fecha = DateFormat("d 'de' MMMM h:mm a", 'es').format(now);

    final caracteres = bodyController.text.characters.length;

    return "$fecha  |  $caracteres caracteres";
  }

  void insertBullet() {
    final text = bodyController.text;
    final selection = bodyController.selection;

    final newText = text.replaceRange(selection.start, selection.end, "• ");

    bodyController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.start + 2),
    );

    setState(() {});
  }

  void insertNumber() {
    final text = bodyController.text;
    final selection = bodyController.selection;

    int lineNumber = 1;

    final lines = text.split('\n');

    for (final line in lines) {
      if (RegExp(r'^\d+\.').hasMatch(line.trim())) {
        lineNumber++;
      }
    }

    final insert = "$lineNumber. ";

    final newText = text.replaceRange(selection.start, selection.end, insert);

    bodyController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + insert.length,
      ),
    );

    setState(() {});
  }

  Future<void> save() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final data = {
        "uid": user.uid,
        "titulo": titleController.text.trim(),
        "cuerpo": bodyController.text.trim(),
        "actualizacion": FieldValue.serverTimestamp(),
      };

      if (isEditing) {
        await FirebaseFirestore.instance
            .collection('notas')
            .doc(widget.noteDoc!.id)
            .update(data);
      } else {
        await FirebaseFirestore.instance.collection('notas').add({
          ...data,
          "fecha_creacion": FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> delete() async {
    if (!isEditing || isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('notas')
          .doc(widget.noteDoc!.id)
          .delete();

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Widget toolButton({
    required IconData icon,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Icon(icon, size: 18, color: theme.colorScheme.secondary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.72,
            ),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // HANDLE
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // TITULO
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: titleController,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onBackground,
                    ),
                    decoration: InputDecoration(
                      hintText: "Título",
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onBackground.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // FECHA + CARACTERES + HERRAMIENTAS
                Row(
                  children: [
                    Expanded(
                      child: AnimatedBuilder(
                        animation: bodyController,
                        builder: (_, __) {
                          return Text(
                            currentInfo(),
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.outline,
                            ),
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 10),

                    toolButton(
                      icon: Icons.format_list_bulleted,
                      onTap: insertBullet,
                      theme: theme,
                    ),

                    const SizedBox(width: 6),

                    toolButton(
                      icon: Icons.format_list_numbered,
                      onTap: insertNumber,
                      theme: theme,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // CUERPO
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: bodyController,
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      autofocus: true,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: theme.colorScheme.onBackground,
                      ),
                      decoration: InputDecoration(
                        hintText: "Empiece a escribir",
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onBackground.withOpacity(
                            0.5,
                          ),
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (_) {
                        setModalState(() {});
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // BOTONES
                Row(
                  children: [
                    if (isEditing)
                      Expanded(
                        child: GestureDetector(
                          onTap: isLoading ? null : delete,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: isLoading
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: theme.colorScheme.error,
                                      ),
                                    )
                                  : Text(
                                      "Eliminar",
                                      style: TextStyle(
                                        color: theme.colorScheme.error,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),

                    if (isEditing) const SizedBox(width: 10),

                    Expanded(
                      child: GestureDetector(
                        onTap: isLoading ? null : save,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: isLoading
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.onSecondary,
                                    ),
                                  )
                                : Text(
                                    "Guardar",
                                    style: TextStyle(
                                      color: theme.colorScheme.onSecondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
