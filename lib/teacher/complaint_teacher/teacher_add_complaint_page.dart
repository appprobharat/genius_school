import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:genius_school/api_service.dart';

class TeacherAddComplaintPage extends StatefulWidget {
  const TeacherAddComplaintPage({super.key});

  @override
  State<TeacherAddComplaintPage> createState() =>
      _TeacherAddComplaintPageState();
}

class _TeacherAddComplaintPageState extends State<TeacherAddComplaintPage> {
  final _formKey = GlobalKey<FormState>();

  // ================= CONTROLLERS =================

  final TextEditingController descriptionController = TextEditingController();

  // ================= STUDENT =================
  List<dynamic> students = [];
  int? selectedStudentId;

  bool isLoadingStudents = false;

  // ================= SUBMIT =================

  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> fetchStudents() async {
    if (!mounted) return;

    setState(() {
      isLoadingStudents = true;
      students.clear();
      selectedStudentId = null;
    });

    try {
      final response = await ApiService.post(context, '/get_student');

      if (response == null || !mounted) return;

      debugPrint("🟢 STUDENT STATUS: ${response.statusCode}");
      debugPrint("📦 STUDENT BODY: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        setState(() {
          students = decoded is List ? decoded : [];
          isLoadingStudents = false;
        });

        debugPrint("📊 ALL STUDENT COUNT: ${students.length}");
      } else {
        setState(() {
          students = [];
          isLoadingStudents = false;
        });

        _showSnackBar("Failed to load students");
      }
    } catch (e) {
      debugPrint("❌ fetchStudents ERROR: $e");

      if (!mounted) return;

      setState(() {
        students = [];
        isLoadingStudents = false;
      });

      _showSnackBar("Error loading students");
    }
  }

  Future<void> submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedStudentId == null) {
      _showSnackBar("Please select a student");
      return;
    }

    setState(() => isSubmitting = true);

    debugPrint("🟡 submitComplaint START");

    try {
      final response = await ApiService.post(
        context,
        '/teacher/complaint/store',
        body: {
          'StudentId': selectedStudentId.toString(),
          'Description': descriptionController.text.trim(),
        },
      );

      if (response == null || !mounted) {
        if (mounted) {
          setState(() => isSubmitting = false);
        }
        return;
      }

      debugPrint("🟢 STATUS CODE: ${response.statusCode}");
      debugPrint("📦 RAW BODY: ${response.body}");

      final decoded = jsonDecode(response.body);

      if (!mounted) return;

      setState(() => isSubmitting = false);

      if (response.statusCode == 200 && decoded['status'] == true) {
        _showSnackBar(decoded['message'] ?? "Complaint submitted");

        Navigator.pop(context, true);
      } else {
        _showSnackBar(decoded['message'] ?? "Submission failed");
      }
    } catch (e) {
      debugPrint("❌ submitComplaint ERROR: $e");

      if (!mounted) return;

      setState(() => isSubmitting = false);

      _showSnackBar("Something went wrong");
    }

    debugPrint("🔚 submitComplaint END");
  }

  void _showSnackBar(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Complaint",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: SingleChildScrollView(
            child: Column(
              children: [
                // ==================================================
                // STUDENT DROPDOWN
                // ==================================================
                DropdownButtonFormField<int>(
                  value: selectedStudentId,
                  isExpanded: true,

                  hint: Text(
                    isLoadingStudents
                        ? "Loading students..."
                        : students.isEmpty
                        ? "No students found"
                        : "Select Student",
                  ),

                  decoration: InputDecoration(
                    labelText: "Student",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),

                  items: students.map<DropdownMenuItem<int>>((student) {
                    final studentId = student['id'] is int
                        ? student['id']
                        : int.tryParse(student['id'].toString());

                    final displayName =
                        "${student['StudentName'] ?? ''} "
                        "S/D/O "
                        "${student['FatherName'] ?? ''}";

                    return DropdownMenuItem<int>(
                      value: studentId,
                      child: Text(
                        displayName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  }).toList(),

                  onChanged: isLoadingStudents
                      ? null
                      : (value) {
                          setState(() {
                            selectedStudentId = value;
                          });
                        },

                  validator: (value) {
                    if (value == null) {
                      return "Please select a student";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ==================================================
                // COMPLAINT DESCRIPTION
                // ==================================================
                TextFormField(
                  controller: descriptionController,

                  maxLines: 4,

                  decoration: InputDecoration(
                    labelText: "Complaint Description",

                    alignLabelWithHint: true,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter complaint description";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // ==================================================
                // SUBMIT BUTTON
                // ==================================================
                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    onPressed: isSubmitting ? null : submitComplaint,

                    icon: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,

                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send),

                    label: Text(isSubmitting ? "Submitting..." : "Submit"),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,

                      foregroundColor: Colors.white,

                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
