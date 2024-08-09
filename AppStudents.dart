import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

import 'Scores.dart';
import 'Subject.dart';

class Student{
  int id;
  String name;
  List<Subject> subjects;

  Student(this.id, this.name, this.subjects);
  Map<String, dynamic> toJson(){
    return{
      'id':id,
      'name':name,
      'subjects':subjects
    };
  }

  static Student fromJson(Map<String,dynamic>json){
    return Student(json['id'], json['name'], json['subjects']);
  }


}

void main()async{
  const String fileName ='students.json';
  final String directoryPath = p.join(Directory.current.path,'data');
  final Directory directory =Directory(directoryPath);

  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }

  final String filePath = p.join(directoryPath, fileName);
  List<Student> studentList = await loadStudents(filePath);

  while (true) {
    print('''
        Menu:
        1. Thêm sinh viên 
        2. Hiển thị thông tin sinh viên 
        3. Sửa thông tin sinh viên 
        4. Tìm kiếm sinh viên theo  ID
        5. Hiển thị sinh viên có điểm thi môn cao nhất
        Mời bạn chọn:
        ''');
    String? choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        await addStudent(filePath, studentList);
        break;
      case '2':
        displayStudents(studentList);
        break;
      case '3':
        await editStudent(filePath, studentList);
        break;
      case '4':
        await searchStudent(filePath, studentList);
        break;
      // case '5'
      //   await displayStudentMaxSocer(filePath, studentList);
      //   break;
      case '6':
        print('Thoát chương trình');
        exit(0);
      default:
        print('Vui lòng chọn lại!');
    }
  }

}


Future<List<Student>> loadStudents(String filePath) async {
  if (!File(filePath).existsSync()) {
    await File(filePath).create();
    await File(filePath).writeAsString(jsonEncode([]));
    return [];
  }
  String content = await File(filePath).readAsString();
  List<dynamic> jsonData = jsonDecode(content);

  return jsonData.map((json) => Student.fromJson(json)).toList();
}

void displayStudents(List<Student> students) {
  for (var student in students) {
    print('ID: ${student.id}, Name: ${student.name}');
    for (var subject in student.subjects) {
      print('  Subject: ${subject.name}, Scores:');
      for (var score in subject.scores) {
        print('    ID: ${score.id}, Score: ${score.score}');
      }
    }
    print('');
  }
}

Future<void> saveStudents(String filePath, List<Student> studentList) async {
  String jsonContent = jsonEncode(studentList.map((s) => s.toJson()).toList());
  await File(filePath).writeAsString(jsonContent);
}

Future<void> addStudent(String filePath, List<Student> studentList) async {
  print('Nhập tên sinh viên: ');
  String? name = stdin.readLineSync();
  if (name == null || name.isEmpty) {
    print('Tên không hợp lệ');
    return;
  }

  List<Subject> subjects = [];

  for (int i = 0; i < 2; i++) {
    print('Nhập môn học ${i + 1}:');
    String? subjectName = stdin.readLineSync();

    if (subjectName == null || subjectName.isEmpty) {
      print('Tên môn học không hợp lệ');
      return;
    }

    List<Score> scores = [];

    for (int j = 0; j < 3; j++) {
      print('Nhập điểm ${j + 1} cho môn học $subjectName:');
      final scoreInput = stdin.readLineSync();
      final score = int.tryParse(scoreInput ?? '');

      if (score == null) {
        print('Điểm không hợp lệ');
        return;
      }

      scores.add(Score(j, score));
    }

    subjects.add(Subject(i,subjectName , scores ));
  }

  int id = studentList.isEmpty ? 1 : studentList.last.id + 1;
  Student student = Student(id, name, subjects);

  studentList.add(student);
  await saveStudents(filePath, studentList);
}

Future<void> editStudent(String filePath, List<Student> studentList) async {
  try {
    print('Nhập ID sinh viên cần tìm:');
    String? idInput = stdin.readLineSync();
    int? id = int.tryParse(idInput ?? '');

    if (id == null) {
      print('ID không hợp lệ');
      return;
    }

    for(var student in studentList){
      if(student.id == id){
        if (student == null) {
          print('Không tìm thấy sinh viên với ID này');
          return;
        }

        // Chỉnh sửa tên sinh viên
        print('Nhập tên mới (để trống nếu không thay đổi):');
        String? newName = stdin.readLineSync();
        if (newName != null && newName.isNotEmpty) {
          student.name = newName;
        }

        for (int i = 0; i < student.subjects.length; i++) {
          print('Môn học ${i + 1}: ${student.subjects[i].name}');
          print('Bạn muốn chỉnh sửa môn học này? (y/n):');
          String? editChoice = stdin.readLineSync();

          if (editChoice != null && editChoice.toLowerCase() == 'y') {
            // Chỉnh sửa tên môn học
            print('Nhập tên môn học mới (để trống nếu không thay đổi):');
            String? newSubjectName = stdin.readLineSync();
            if (newSubjectName != null && newSubjectName.isNotEmpty) {
              student.subjects[i].name = newSubjectName;
            }

            // Chỉnh sửa điểm số cho môn học
            for (int j = 0; j < student.subjects[i].scores.length; j++) {
              print('Điểm ${j + 1} hiện tại: ${student.subjects[i].scores[j]}');
              print('Nhập điểm mới (để trống nếu không thay đổi):');
              String? newScoreInput = stdin.readLineSync();
              int? newScore = int.tryParse(newScoreInput ?? '');

              if (newScore != null) {
                student.subjects[i].scores[j] = newScore as Score;
              }
            }
      }
    }

      }
    }

    await saveStudents(filePath, studentList);
    print('Cập nhật thông tin sinh viên thành công');
  } catch (e) {
    print('Đã xảy ra lỗi: $e');
  }
}

Future<void> searchStudent(String filePath, List<Student> studentList) async {
  print('Nhập ID sinh viên cần tìm:');
  String? idInput = stdin.readLineSync();
  int? id = int.tryParse(idInput ?? '');

  if (id == null) {
    print('ID không hợp lệ');
    return;
  }

  // Tìm sinh viên theo ID
  for(var student in studentList){
    if(student.id == id){
      if (student.id == -1) {
        print('Không tìm thấy sinh viên với ID này');
      } else {
        print('Thông tin sinh viên:');
        print('ID: ${student.id}');
        print('Tên: ${student.name}');
        // Hiển thị thông tin môn học nếu cần
        for (var subject in student.subjects) {
          print('Môn học: ${subject.name}');
          print('Điểm: ${subject.scores}');
        }
      }
    }
  }

}

Future<void> displayStudentMaxScore(String filePath, List<Student> studentList) async {
  try {
    if (studentList.isEmpty) {
      print('Danh sách sinh viên trống');
      return;
    }

    // Biến lưu trữ sinh viên có điểm số cao nhất và điểm số cao nhất
    Student? topStudent;
    int highestScore = -1;

    // Tìm sinh viên có điểm cao nhất
    for (var student in studentList) {
      for (var subject in student.subjects) {
        for (var score in subject.scores) {
          if (score.score > highestScore) {
            highestScore = score.score;
            topStudent = student;
          }
        }
      }
    }

    if (topStudent == null) {
      print('Không tìm thấy sinh viên có điểm số');
    } else {
      // Hiển thị thông tin sinh viên có điểm cao nhất
      print('Sinh viên có điểm cao nhất:');
      print('ID: ${topStudent.id}');
      print('Tên: ${topStudent.name}');
      print('Điểm cao nhất: $highestScore');
    }

  } catch (e) {
    print('Đã xảy ra lỗi: $e');
  }
}
