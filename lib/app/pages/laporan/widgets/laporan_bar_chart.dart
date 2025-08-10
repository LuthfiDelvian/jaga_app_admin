import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LaporanBarChart extends StatefulWidget {
  const LaporanBarChart({super.key});

  @override
  State<LaporanBarChart> createState() => _LaporanBarChartState();
}

class _LaporanBarChartState extends State<LaporanBarChart> {
  int selectedWeek = 0;
  int? touchedBarIndex; // Bar yang di-tap

  final List<Color> statusColors = [Colors.blue, Colors.green, Colors.red];
  final List<String> statusLabels = ['Masuk', 'Terverifikasi', 'Ditolak'];

  List<List<DateTime>> _weeksOfMonth(DateTime month) {
    List<List<DateTime>> weeks = [];
    DateTime firstDay = DateTime(month.year, month.month, 1);
    int daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    DateTime firstMonday = firstDay.subtract(
      Duration(days: firstDay.weekday - 1),
    );
    int weekCount = 0;
    while (true) {
      List<DateTime> week = [];
      for (int i = 0; i < 7; i++) {
        DateTime day = firstMonday.add(Duration(days: weekCount * 7 + i));
        if (day.month != month.month && day.isAfter(firstDay)) break;
        if (day.month == month.month) week.add(day);
      }
      if (week.isEmpty) break;
      weeks.add(week);
      weekCount++;
      if (week.last.day == daysInMonth) break;
    }
    return weeks;
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    List<List<DateTime>> weeks = _weeksOfMonth(now);
    int weekDropdownCount = weeks.length;

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.red.shade200, width: 1.5),
        borderRadius: BorderRadius.circular(18),
      ),
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Judul & Dropdown filter week
            Row(
              children: [
                Text(
                  'Laporan Mingguan (${_bulanIndo(now.month)} ${now.year})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                DropdownButton<int>(
                  value: selectedWeek,
                  items: List.generate(
                    weekDropdownCount,
                    (i) => DropdownMenuItem(
                      value: i,
                      child: Text('Week ${i + 1}'),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      if (val != null) selectedWeek = val;
                      touchedBarIndex = null;
                    });
                  },
                  style: const TextStyle(fontSize: 13, color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                  underline: const SizedBox(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('laporan').snapshots(),
              builder: (context, snapshot) {
                List<int> masuk = [];
                List<int> verif = [];
                List<int> ditolak = [];

                final thisWeekDays = weeks[selectedWeek];
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  masuk = List.filled(thisWeekDays.length, 0);
                  verif = List.filled(thisWeekDays.length, 0);
                  ditolak = List.filled(thisWeekDays.length, 0);

                  for (final doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final Timestamp? tgl = data['createdAt'];
                    if (tgl == null) continue;
                    final date = tgl.toDate();
                    for (int i = 0; i < thisWeekDays.length; i++) {
                      if (date.year == thisWeekDays[i].year &&
                          date.month == thisWeekDays[i].month &&
                          date.day == thisWeekDays[i].day) {
                        final status =
                            (data['status'] ?? '').toString().toLowerCase();
                        if (status == 'menunggu')
                          masuk[i]++;
                        else if (status == 'diproses' || status == 'selesai')
                          verif[i]++;
                        else if (status == 'ditolak')
                          ditolak[i]++;
                      }
                    }
                  }
                }

                // Tampilkan di legend, jika bar di-tap
                int? showMasuk, showVerif, showDitolak;
                if (touchedBarIndex != null &&
                    masuk.length > touchedBarIndex! &&
                    verif.length > touchedBarIndex! &&
                    ditolak.length > touchedBarIndex!) {
                  showMasuk = masuk[touchedBarIndex!];
                  showVerif = verif[touchedBarIndex!];
                  showDitolak = ditolak[touchedBarIndex!];
                }

                // === LEGEND ===
                return Column(
                  children: [
                    Wrap(
                      spacing: 10, // jarak horizontal antar legend
                      runSpacing: 8, // jarak vertikal kalau turun baris
                      children: [
                        _LegendBlock(
                          color: statusColors[0],
                          label: statusLabels[0],
                          value: showMasuk,
                        ),
                        _LegendBlock(
                          color: statusColors[1],
                          label: statusLabels[1],
                          value: showVerif,
                        ),
                        _LegendBlock(
                          color: statusColors[2],
                          label: statusLabels[2],
                          value: showDitolak,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    // === CHART ===
                    SizedBox(
                      height: 230,
                      child: BarChart(
                        BarChartData(
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              tooltipPadding: EdgeInsets.zero,
                              tooltipMargin: 0,
                              getTooltipItem:
                                  (group, groupIndex, rod, rodIndex) => null,
                            ),
                            touchCallback: (event, response) {
                              if (event.isInterestedForInteractions &&
                                  response != null &&
                                  response.spot != null) {
                                setState(() {
                                  touchedBarIndex =
                                      response.spot!.touchedBarGroupIndex;
                                });
                              } else {
                                setState(() {
                                  touchedBarIndex = null;
                                });
                              }
                            },
                          ),
                          barGroups: List.generate(thisWeekDays.length, (
                            groupIdx,
                          ) {
                            double y0 =
                                masuk.isNotEmpty
                                    ? masuk[groupIdx].toDouble()
                                    : 0;
                            double y1 =
                                verif.isNotEmpty
                                    ? verif[groupIdx].toDouble()
                                    : 0;
                            double y2 =
                                ditolak.isNotEmpty
                                    ? ditolak[groupIdx].toDouble()
                                    : 0;
                            return BarChartGroupData(
                              x: groupIdx,
                              barRods: [
                                BarChartRodData(
                                  toY: y0 + y1 + y2,
                                  rodStackItems: [
                                    BarChartRodStackItem(
                                      0,
                                      y0,
                                      statusColors[0],
                                    ),
                                    BarChartRodStackItem(
                                      y0,
                                      y0 + y1,
                                      statusColors[1],
                                    ),
                                    BarChartRodStackItem(
                                      y0 + y1,
                                      y0 + y1 + y2,
                                      statusColors[2],
                                    ),
                                  ],
                                  width: 20,
                                  borderRadius: BorderRadius.circular(6),
                                  // highlight batang yg dipilih
                                  color:
                                      touchedBarIndex == groupIdx
                                          ? Colors.black12
                                          : null,
                                ),
                              ],
                            );
                          }),
                          groupsSpace: 13,
                          maxY: [
                                for (int g = 0; g < thisWeekDays.length; g++)
                                  (masuk.isNotEmpty ? masuk[g] : 0) +
                                      (verif.isNotEmpty ? verif[g] : 0) +
                                      (ditolak.isNotEmpty ? ditolak[g] : 0),
                              ]
                              .fold<double>(
                                0,
                                (p, e) => e > p ? e.toDouble() : p,
                              )
                              .let(
                                (maxY) =>
                                    maxY < 5
                                        ? maxY.ceilToDouble()
                                        : ((maxY / 5).ceil() * 5).toDouble(),
                              )
                              .let((maxY) => maxY == 0 ? 5 : maxY),
                          minY: 0,
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 36,
                                interval: 1,
                                getTitlesWidget:
                                    (value, meta) => Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  int idx = value.toInt();
                                  if (idx < 0 || idx >= thisWeekDays.length)
                                    return const SizedBox();
                                  DateTime tgl = thisWeekDays[idx];
                                  String hari =
                                      [
                                        'Sun',
                                        'Mon',
                                        'Tue',
                                        'Wed',
                                        'Thu',
                                        'Fri',
                                        'Sat',
                                      ][tgl.weekday % 7];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      '${hari}\n${tgl.day}',
                                      style: const TextStyle(fontSize: 11),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            horizontalInterval: 1,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine:
                                (value) => FlLine(
                                  color: Colors.grey[300],
                                  strokeWidth: 1,
                                ),
                          ),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _bulanIndo(int m) {
    const bln = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return bln[m];
  }
}

class _LegendBlock extends StatelessWidget {
  final Color color;
  final String label;
  final int? value;
  const _LegendBlock({required this.color, required this.label, this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 18),
      child: Row(
        children: [
          Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
            margin: const EdgeInsets.only(right: 4),
          ),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.black87)),
          if (value != null)
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(
                value.toString(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Untuk .let ekstensi, jika error, bisa ganti manual atau tambahkan:
extension Let<T> on T {
  R let<R>(R Function(T) op) => op(this);
}
