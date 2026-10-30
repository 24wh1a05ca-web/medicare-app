
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MediCareApp());
}

// ---------------- DOCTOR MODEL ----------------

class Doctor {
  final String name;
  final String specialty;
  final String qualification;
  final double fee;
  final double rating;
  final IconData icon;
  final Color color;
  final String experience;

  const Doctor({
    required this.name,
    required this.specialty,
    required this.qualification,
    required this.fee,
    required this.rating,
    required this.icon,
    required this.color,
    required this.experience,
  });
}

const List<Doctor> doctors = [
  Doctor(
    name: 'Dr. Ananya Sharma',
    specialty: 'Cardiologist',
    qualification: 'MBBS, MD Cardiology',
    fee: 500,
    rating: 4.9,
    icon: Icons.favorite,
    color: Colors.red,
    experience: '12 years',
  ),
  Doctor(
    name: 'Dr. Rahul Reddy',
    specialty: 'Dentist',
    qualification: 'BDS, MDS',
    fee: 300,
    rating: 4.8,
    icon: Icons.medical_services,
    color: Colors.blue,
    experience: '8 years',
  ),
  Doctor(
    name: 'Dr. Priya Kumar',
    specialty: 'Dermatologist',
    qualification: 'MBBS, MD Dermatology',
    fee: 400,
    rating: 4.7,
    icon: Icons.face,
    color: Colors.purple,
    experience: '10 years',
  ),
  Doctor(
    name: 'Dr. Arjun Rao',
    specialty: 'Neurologist',
    qualification: 'MBBS, DM Neurology',
    fee: 600,
    rating: 4.9,
    icon: Icons.psychology,
    color: Colors.orange,
    experience: '15 years',
  ),
  Doctor(
    name: 'Dr. Sneha Reddy',
    specialty: 'Pediatrician',
    qualification: 'MBBS, MD Pediatrics',
    fee: 350,
    rating: 4.8,
    icon: Icons.child_care,
    color: Colors.teal,
    experience: '7 years',
  ),
  Doctor(
    name: 'Dr. Kiran Kumar',
    specialty: 'Orthopedic',
    qualification: 'MBBS, MS Orthopedics',
    fee: 450,
    rating: 4.6,
    icon: Icons.accessibility_new,
    color: Colors.indigo,
    experience: '9 years',
  ),
];

// ---------------- APPOINTMENT MODEL ----------------

class Appointment {
  final String id;
  final String doctor;
  final String specialty;
  final String date;
  final String time;
  final double fee;

  Appointment({
    required this.id,
    required this.doctor,
    required this.specialty,
    required this.date,
    required this.time,
    required this.fee,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'doctor': doctor,
        'specialty': specialty,
        'date': date,
        'time': time,
        'fee': fee,
      };

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      doctor: json['doctor'],
      specialty: json['specialty'],
      date: json['date'],
      time: json['time'],
      fee: (json['fee'] as num).toDouble(),
    );
  }
}

// ---------------- MAIN APP ----------------

class MediCareApp extends StatefulWidget {
  const MediCareApp({super.key});

  @override
  State<MediCareApp> createState() => _MediCareAppState();
}

class _MediCareAppState extends State<MediCareApp> {
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  int selectedIndex = 0;
  bool darkMode = false;
  bool loading = true;
  List<Appointment> appointments = [];

  @override
  void initState() {
    super.initState();
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('appointments');

    if (saved != null) {
      try {
        final List data = jsonDecode(saved);
        appointments =
            data.map((e) => Appointment.fromJson(e)).toList();
      } catch (_) {
        appointments = [];
      }
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> saveAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final data = appointments.map((e) => e.toJson()).toList();
    await prefs.setString('appointments', jsonEncode(data));
  }

  void addAppointment(Appointment appointment) {
    setState(() {
      appointments.add(appointment);
      selectedIndex = 2;
    });
    saveAppointments();
  }

  void cancelAppointment(String id) {
    setState(() {
      appointments.removeWhere((a) => a.id == id);
    });
    saveAppointments();
  }

  void clearAppointments() {
    setState(() => appointments.clear());
    saveAppointments();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        appointments: appointments,
        onDoctorTap: openDoctor,
        onViewAll: () => setState(() => selectedIndex = 1),
      ),
      DoctorsScreen(onDoctorTap: openDoctor),
      AppointmentsScreen(
        appointments: appointments,
        onCancel: cancelAppointment,
      ),
      ProfileScreen(
        darkMode: darkMode,
        onThemeChanged: (value) {
          setState(() => darkMode = value);
        },
        onClear: clearAppointments,
      ),
    ];

    return MaterialApp(
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'MediCare',
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1677C8),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F8FC),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1677C8),
          brightness: Brightness.dark,
        ),
      ),
      home: loading
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : Scaffold(
              body: IndexedStack(
                index: selectedIndex,
                children: pages,
              ),
              bottomNavigationBar: NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) {
                  setState(() => selectedIndex = index);
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.medical_services_outlined),
                    selectedIcon: Icon(Icons.medical_services),
                    label: 'Doctors',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.calendar_month_outlined),
                    selectedIcon: Icon(Icons.calendar_month),
                    label: 'Appointments',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
    );
  }

  void openDoctor(Doctor doctor) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => DoctorDetailsScreen(
          doctor: doctor,
          onBook: (appointment) {
            addAppointment(appointment);
            navigatorKey.currentState?.pop();

            scaffoldMessengerKey.currentState?.showSnackBar(
              const SnackBar(
                content: Text('Appointment booked successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------- COMMON WIDGETS ----------------

Widget sectionTitle(String title, {VoidCallback? onTap}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
      ),
      if (onTap != null)
        TextButton(
          onPressed: onTap,
          child: const Text('See all'),
        ),
    ],
  );
}

Widget doctorAvatar(Doctor doctor, {double size = 65}) {
  return CircleAvatar(
    radius: size / 2,
    backgroundColor: doctor.color.withValues(alpha: 0.13),
    child: Icon(
      doctor.icon,
      color: doctor.color,
      size: size * 0.48,
    ),
  );
}

Widget doctorCard(
  Doctor doctor,
  VoidCallback onTap, {
  bool compact = false,
}) {
  return Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            doctorAvatar(doctor),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor.specialty,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: Colors.amber, size: 16),
                      Text(' ${doctor.rating}'),
                      const SizedBox(width: 10),
                      Text(
                        doctor.experience,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!compact)
              Column(
                children: [
                  Text(
                    '₹${doctor.fee.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Color(0xFF1677C8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Fee',
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
            const SizedBox(width: 5),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    ),
  );
}

// ---------------- HOME SCREEN ----------------

class HomeScreen extends StatelessWidget {
  final List<Appointment> appointments;
  final Function(Doctor) onDoctorTap;
  final VoidCallback onViewAll;

  const HomeScreen({
    super.key,
    required this.appointments,
    required this.onDoctorTap,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final upcoming = appointments.isNotEmpty
        ? appointments.last
        : null;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFF1677C8),
                child: Icon(Icons.favorite,
                    color: Colors.white),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MediCare',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Your Health, Our Priority',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.notifications_none, size: 28),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Hello, Patient! 👋',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const Text(
            'Find the right doctor for your health.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1677C8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Health Matters!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Book your appointment with trusted doctors.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.medical_services,
                  color: Colors.white,
                  size: 65,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          sectionTitle('Medical Specialities'),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _speciality(context, 'Heart', Icons.favorite,
                    Colors.red, doctors[0], onDoctorTap),
                _speciality(context, 'Dental', Icons.mood,
                    Colors.blue, doctors[1], onDoctorTap),
                _speciality(context, 'Skin', Icons.face,
                    Colors.purple, doctors[2], onDoctorTap),
                _speciality(context, 'Brain', Icons.psychology,
                    Colors.orange, doctors[3], onDoctorTap),
                _speciality(context, 'Children', Icons.child_care,
                    Colors.teal, doctors[4], onDoctorTap),
              ],
            ),
          ),
          const SizedBox(height: 22),
          if (upcoming != null) ...[
            sectionTitle('Your Recent Booking'),
            Card(
              elevation: 0,
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.calendar_month),
                ),
                title: Text(upcoming.doctor),
                subtitle: Text('${upcoming.date} • ${upcoming.time}'),
                trailing: const Icon(Icons.check_circle,
                    color: Colors.green),
              ),
            ),
            const SizedBox(height: 15),
          ],
          sectionTitle('Top Doctors', onTap: onViewAll),
          const SizedBox(height: 10),
          ...doctors.take(3).map(
                (doctor) => doctorCard(
                  doctor,
                  () => onDoctorTap(doctor),
                ),
              ),
        ],
      ),
    );
  }

  Widget _speciality(
    BuildContext context,
    String name,
    IconData icon,
    Color color,
    Doctor doctor,
    Function(Doctor) onTap,
  ) {
    return GestureDetector(
      onTap: () => onTap(doctor),
      child: Container(
        width: 78,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 29,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 27),
            ),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ---------------- DOCTORS SCREEN ----------------

class DoctorsScreen extends StatefulWidget {
  final Function(Doctor) onDoctorTap;

  const DoctorsScreen({
    super.key,
    required this.onDoctorTap,
  });

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  String search = '';
  String category = 'All';

  final categories = [
    'All',
    'Cardiologist',
    'Dentist',
    'Dermatologist',
    'Neurologist',
    'Pediatrician',
    'Orthopedic',
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = doctors.where((doctor) {
      final matchesSearch =
          doctor.name.toLowerCase().contains(search.toLowerCase()) ||
          doctor.specialty.toLowerCase().contains(search.toLowerCase());

      final matchesCategory =
          category == 'All' || doctor.specialty == category;

      return matchesSearch && matchesCategory;
    }).toList();

    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Find Doctors',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search doctor or speciality...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() => search = value);
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: categories.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(item),
                    selected: category == item,
                    onSelected: (_) {
                      setState(() => category = item);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No doctors found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final doctor = filtered[index];
                      return doctorCard(
                        doctor,
                        () => widget.onDoctorTap(doctor),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------- DOCTOR DETAILS AND BOOKING ----------------

class DoctorDetailsScreen extends StatefulWidget {
  final Doctor doctor;
  final Function(Appointment) onBook;

  const DoctorDetailsScreen({
    super.key,
    required this.doctor,
    required this.onBook,
  });

  @override
  State<DoctorDetailsScreen> createState() =>
      _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState
    extends State<DoctorDetailsScreen> {
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  String? selectedTime;

  final times = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;

    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),
          Center(child: doctorAvatar(doctor, size: 110)),
          const SizedBox(height: 15),
          Center(
            child: Text(
              doctor.name,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Center(
            child: Text(
              doctor.specialty,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 15),
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(doctor.qualification),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _info('Experience', doctor.experience),
                      _info('Rating', '⭐ ${doctor.rating}'),
                      _info('Consultation', '₹${doctor.fee}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            'Select Appointment Date',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(
                  const Duration(days: 90),
                ),
              );
              if (date != null) {
                setState(() => selectedDate = date);
              }
            },
            icon: const Icon(Icons.calendar_month),
            label: Text(
              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Select Time Slot',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: times.map((time) {
              return ChoiceChip(
                label: Text(time),
                selected: selectedTime == time,
                onSelected: (_) {
                  setState(() => selectedTime = time);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: selectedTime == null
                  ? null
                  : () => _confirmBooking(),
              child: const Text(
                'Confirm Appointment',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  void _confirmBooking() {
    final appointment = Appointment(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      doctor: widget.doctor.name,
      specialty: widget.doctor.specialty,
      date:
          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
      time: selectedTime!,
      fee: widget.doctor.fee,
    );

    widget.onBook(appointment);
  }
}

// ---------------- APPOINTMENTS SCREEN ----------------

class AppointmentsScreen extends StatelessWidget {
  final List<Appointment> appointments;
  final Function(String) onCancel;

  const AppointmentsScreen({
    super.key,
    required this.appointments,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'My Appointments',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: appointments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_month,
                          size: 75,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No appointments yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Book your first doctor appointment.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appointment =
                          appointments[index];

                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 14),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          appointment.doctor,
                                          style: const TextStyle(
                                            fontWeight:
                                                FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          appointment.specialty,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                ],
                              ),
                              const Divider(height: 25),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 7),
                                  Text(appointment.date),
                                  const SizedBox(width: 18),
                                  const Icon(
                                    Icons.access_time,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 7),
                                  Text(appointment.time),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Consultation: ₹${appointment.fee.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _showCancelDialog(
                                        context,
                                        appointment.id,
                                      );
                                    },
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Appointment?'),
        content: const Text(
          'Are you sure you want to cancel this appointment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () {
              onCancel(id);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appointment cancelled'),
                ),
              );
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

// ---------------- PROFILE SCREEN ----------------

class ProfileScreen extends StatelessWidget {
  final bool darkMode;
  final ValueChanged<bool> onThemeChanged;
  final VoidCallback onClear;

  const ProfileScreen({
    super.key,
    required this.darkMode,
    required this.onThemeChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'My Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),
          const Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Color(0xFF1677C8),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 55,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Patient User',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Center(
            child: Text(
              'patient@example.com',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Settings',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 0,
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode),
              title: const Text('Dark Mode'),
              subtitle: const Text('Change app appearance'),
              value: darkMode,
              onChanged: onThemeChanged,
            ),
          ),
          Card(
            elevation: 0,
            child: const ListTile(
              leading: Icon(Icons.currency_rupee),
              title: Text('Currency'),
              subtitle: Text('Indian Rupee (INR)'),
              trailing: Text('₹'),
            ),
          ),
          Card(
            elevation: 0,
            child: ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
              title: const Text('Clear All Appointments'),
              onTap: () => _clearDialog(context),
            ),
          ),
          const SizedBox(height: 25),
          const Center(
            child: Text(
              'MediCare App v1.0.0',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  void _clearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Appointments?'),
        content: const Text(
          'This will delete all saved appointments. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              onClear();
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All appointments cleared'),
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
