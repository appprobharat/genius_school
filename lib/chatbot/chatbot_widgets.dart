import 'package:flutter/material.dart';

class ChatbotWidgets extends StatelessWidget {
  final Map<String, dynamic> attendance;
  final List<dynamic> homeworks;
  final String todayStatus;
  final int subjects;
  final double dues;
  final double siblingDues;
  final double fine;
  final int payments;
  final String paymentDate;
  final String type;

  const ChatbotWidgets({
    Key? key,
    required this.attendance,
    required this.homeworks,
    required this.todayStatus,
    required this.subjects,
    required this.dues,
    required this.siblingDues,
    required this.fine,
    required this.payments,
    required this.paymentDate,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case "fee":
        return _buildFeeCard(context);

      case "attendance":
        return _buildAttendanceCard(context);

      case "homework":
        return _buildHomeworkCard(context);

      case "today":
        return _buildTodayCard(context);

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAttendanceCard(BuildContext context) {
    final int present =
        int.tryParse(attendance["present"]?.toString() ?? "0") ?? 0;

    final int absent =
        int.tryParse(attendance["absent"]?.toString() ?? "0") ?? 0;

    final int halfDay =
        int.tryParse(attendance["half_day"]?.toString() ?? "0") ?? 0;

    final int leave = int.tryParse(attendance["leave"]?.toString() ?? "0") ?? 0;

    final int workingDays =
        int.tryParse(attendance["working_days"]?.toString() ?? "0") ?? 0;

    final double percentage = workingDays > 0
        ? (present / workingDays) * 100
        : 0;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFE8EAF6),
                  child: Icon(
                    Icons.bar_chart_rounded,
                    color: Colors.indigo,
                    size: 20,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Attendance Summary",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Text(
                  "${percentage.toStringAsFixed(1)}%",
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const Spacer(),
                Text(
                  "$workingDays Working Days",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (percentage / 100).clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: const Color(0xFFE8EAF6),
                color: Colors.indigo,
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: _attendanceBox(
                    "Present",
                    present,
                    Icons.check_circle_rounded,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _attendanceBox(
                    "Absent",
                    absent,
                    Icons.cancel_rounded,
                    Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _attendanceBox(
                    "Leave",
                    leave,
                    Icons.event_busy_rounded,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _attendanceBox(
                    "Half Day",
                    halfDay,
                    Icons.timelapse_rounded,
                    Colors.blue,
                  ),
                ),
              ],
            ),

            if (workingDays == 0) ...[
              const SizedBox(height: 14),
              const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Attendance data is not available yet.",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _attendanceBox(String title, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeworkCard(BuildContext context) {
    if (homeworks.isEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Text(
            "📚 No homework is available right now.",
            style: TextStyle(fontSize: 14, color: Color(0xFF333333)),
          ),
        ),
      );
    }

    final latestHomework = homeworks.take(3).toList();

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.88,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFE8EAF6),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: Colors.indigo,
                    size: 19,
                  ),
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    "Recent Homework",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EAF6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${homeworks.length}",
                    style: const TextStyle(
                      color: Colors.indigo,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            ...latestHomework.asMap().entries.map((entry) {
              final index = entry.key;

              // Convert dynamic item safely to Map
              final Map<String, dynamic> homework = Map<String, dynamic>.from(
                entry.value as Map,
              );

              final String title =
                  homework["HomeworkTitle"]?.toString() ?? "Homework";

              final String workDate = homework["WorkDate"]?.toString() ?? "-";

              final String submissionDate =
                  homework["SubmissionDate"]?.toString() ?? "-";

              final String remark = homework["Remark"]?.toString() ?? "";

              final String attachment =
                  homework["Attachment"]?.toString() ?? "";

              return Column(
                children: [
                  _homeworkItem(
                    title: title,
                    workDate: workDate,
                    submissionDate: submissionDate,
                    remark: remark,
                    hasAttachment:
                        attachment.isNotEmpty && attachment != "null",
                  ),

                  if (index != latestHomework.length - 1)
                    const Divider(height: 24),
                ],
              );
            }),

            if (homeworks.length > 3) ...[
              const SizedBox(height: 12),

              Center(
                child: Text(
                  "+ ${homeworks.length - 3} more homework",
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _homeworkItem({
    required String title,
    required String workDate,
    required String submissionDate,
    required String remark,
    required bool hasAttachment,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.assignment_rounded,
            color: Colors.indigo,
            size: 18,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                "Work: $workDate",
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),

              Text(
                "Submit: $submissionDate",
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),

              if (remark.isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(
                  remark,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF555555),
                  ),
                ),
              ],

              if (hasAttachment) ...[
                const SizedBox(height: 6),

                const Row(
                  children: [
                    Icon(
                      Icons.attach_file_rounded,
                      size: 14,
                      color: Colors.indigo,
                    ),
                    SizedBox(width: 3),
                    Text(
                      "Attachment available",
                      style: TextStyle(
                        color: Colors.indigo,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTodayCard(BuildContext context) {
    final bool attendanceMarked = todayStatus != "not_mark";

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.86,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.indigo.shade50, Colors.white],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.indigo.withOpacity(0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.indigo,
                  child: Icon(
                    Icons.wb_sunny_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                ),

                SizedBox(width: 10),

                Text(
                  "Today's Update",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),

            const SizedBox(height: 17),

            _todayRow(
              attendanceMarked
                  ? Icons.check_circle_rounded
                  : Icons.access_time_filled_rounded,
              "Attendance",
              attendanceMarked ? todayStatus : "Not marked yet",
              attendanceMarked ? Colors.green : Colors.orange,
            ),

            _todayRow(
              Icons.menu_book_rounded,
              "Subjects",
              "$subjects Subjects",
              Colors.blue,
            ),

            _todayRow(
              Icons.account_balance_wallet_rounded,
              "Fee Due",
              "₹${dues.toStringAsFixed(0)}",
              dues > 0 ? Colors.red : Colors.green,
            ),

            _todayRow(
              Icons.assignment_rounded,
              "Homework",
              "${homeworks.length} Available",
              Colors.deepPurple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _todayRow(IconData icon, String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 17),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
            ),
          ),

          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ================= FEE CARD =================
  Widget _buildFeeCard(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.82,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFE8EAF6),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.indigo,
                    size: 19,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  "Fee Summary",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _feeRow(
              "Due Fee",
              "₹${dues.toStringAsFixed(0)}",
              Icons.currency_rupee,
            ),

            _feeRow(
              "Sibling Due",
              "₹${siblingDues.toStringAsFixed(0)}",
              Icons.people_alt_rounded,
            ),

            _feeRow(
              "Fine",
              "₹${fine.toStringAsFixed(0)}",
              Icons.warning_amber_rounded,
            ),

            const Divider(height: 24),

            Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  size: 17,
                  color: Colors.grey,
                ),
                const SizedBox(width: 7),
                Text(
                  "$payments Payments",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                Text(
                  paymentDate,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _feeRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.indigo),

          const SizedBox(width: 9),

          Text(
            title,
            style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
          ),

          const Spacer(),

          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF222222),
            ),
          ),
        ],
      ),
    );
  }
}
