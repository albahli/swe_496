import 'package:flutter_test/flutter_test.dart';
import 'package:swe496/Database/ProjectCollection.dart';
void main() {
  test('ProjectCollection ...', () async {
    // TODO: Implement test

    // ARRANGE
     ProjectCollection pc = new ProjectCollection();
     List<String> members= ["sss","sss","sss"];
    // ASSERT 
     expect(pc.createNewProject("test",members),true);
  });
}