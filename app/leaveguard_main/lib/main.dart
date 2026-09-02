import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const LeaveGuardApp());
}

// ── 색상 팔레트 ──────────────────────────────────────────────
const kBgLeft = Color(0xFF101B26); // 왼쪽 패널 배경
const kBgRight = Color(0xFF0A121A); // 오른쪽 메인 배경
const kCard = Color(0xFF18242F); // 카드 배경
const kTextMain = Color(0xFFE9EEF3);
const kTextSub = Color(0xFF8B99A6);
const kGreen = Color(0xFF4ADE80);
const kAmber = Color(0xFFF5B84B);
const kBlue = Color(0xFF4BA3F5);

class LeaveGuardApp extends StatelessWidget {
  const LeaveGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LeaveGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, fontFamily: 'sans-serif'),
      home: const IdleScreen(),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  대기 화면: 좌측 정보 패널 + 우측 인식 안내
// ════════════════════════════════════════════════════════════
class IdleScreen extends StatelessWidget {
  const IdleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(width: 340, color: kBgLeft, child: const SidePanel()),
          Expanded(child: Container(color: kBgRight, child: const WelcomeArea())),
        ],
      ),
    );
  }
}

// ── 좌측 패널 ────────────────────────────────────────────────
class SidePanel extends StatelessWidget {
  const SidePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ClockBlock(),
          const SizedBox(height: 28),
          const WeatherCard(),
          const SizedBox(height: 12),
          const IndoorCard(),
          const Spacer(),
          const DeviceRow(name: '고데기', status: 'OFF', color: kGreen),
          const DeviceRow(name: '전기포트', status: 'OFF', color: kGreen),
          const DeviceRow(name: '거실 조명', status: 'ON', color: kAmber),
          const SizedBox(height: 20),
          Row(children: [
            const _Dot(color: kGreen),
            const SizedBox(width: 10),
            Text('AI LeaveGuard',
                style: TextStyle(color: kTextSub, fontSize: 15)),
          ]),
        ],
      ),
    );
  }
}

// 시계 + 날짜 (1초마다 갱신)
class ClockBlock extends StatefulWidget {
  const ClockBlock({super.key});

  @override
  State<ClockBlock> createState() => _ClockBlockState();
}

class _ClockBlockState extends State<ClockBlock> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    final hh = _now.hour.toString().padLeft(2, '0');
    final mm = _now.minute.toString().padLeft(2, '0');
    final date =
        '${_now.month}월 ${_now.day}일 ${_weekdays[_now.weekday - 1]}요일';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$hh:$mm',
            style: const TextStyle(
                color: kTextMain,
                fontSize: 68,
                fontWeight: FontWeight.w700,
                height: 1.0)),
        const SizedBox(height: 6),
        Text(date, style: const TextStyle(color: kTextSub, fontSize: 18)),
      ],
    );
  }
}

// 날씨 카드 (지금은 목업 값 — 추후 Weather 서비스 연동)
class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: kCard, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
                color: Color(0xFF223243), shape: BoxShape.circle),
            child: const Center(
              child:
                  Icon(Icons.water_drop_rounded, color: kBlue, size: 22),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('21°  비',
                  style: TextStyle(
                      color: kTextMain,
                      fontSize: 21,
                      fontWeight: FontWeight.w700)),
              SizedBox(height: 2),
              Text('강수확률 80%',
                  style: TextStyle(color: kTextSub, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

// 실내 / 습도 / 현관 카드
class IndoorCard extends StatelessWidget {
  const IndoorCard({super.key});

  @override
  Widget build(BuildContext context) {
    Widget item(String label, String value) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: kTextSub, fontSize: 13)),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    color: kTextMain,
                    fontSize: 19,
                    fontWeight: FontWeight.w700)),
          ],
        );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
          color: kCard, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          item('실내', '23.5°'),
          item('습도', '48%'),
          item('현관', '닫힘'),
        ],
      ),
    );
  }
}

// 기기 상태 한 줄
class DeviceRow extends StatelessWidget {
  const DeviceRow(
      {super.key,
      required this.name,
      required this.status,
      required this.color});
  final String name;
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          _Dot(color: color),
          const SizedBox(width: 12),
          Text(name, style: const TextStyle(color: kTextMain, fontSize: 16)),
          const Spacer(),
          Text(status,
              style: TextStyle(
                  color: color, fontSize: 15, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ── 우측 메인: 인식 대기 안내 ────────────────────────────────
class WelcomeArea extends StatelessWidget {
  const WelcomeArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFF16222E),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF243342), width: 2),
            ),
            child: const Icon(Icons.person_rounded,
                color: Color(0xFF4A5C6E), size: 96),
          ),
          const SizedBox(height: 44),
          const Text('현관 앞에 서면 자동으로 인식합니다',
              style: TextStyle(
                  color: kTextMain,
                  fontSize: 30,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          const Text('가족 구성원별 외출 체크리스트를 준비해드려요',
              style: TextStyle(color: kTextSub, fontSize: 18)),
        ],
      ),
    );
  }
}
