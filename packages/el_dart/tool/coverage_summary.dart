import 'dart:io';

void main(List<String> args) {
  final lcovPath = args.isEmpty ? 'coverage/lcov.info' : args.first;
  final file = File(lcovPath);
  if (!file.existsSync()) {
    stderr.writeln('lcov not found: $lcovPath');
    exitCode = 2;
    return;
  }

  final lines = file.readAsLinesSync();

  String? current;
  final totals = <String, ({int hit, int total})>{};
  final uncovered = <String, List<int>>{};

  void ensure(String path) {
    totals.putIfAbsent(path, () => (hit: 0, total: 0));
    uncovered.putIfAbsent(path, () => <int>[]);
  }

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      current = line.substring(3);
      ensure(current);
      continue;
    }
    if (current == null) continue;

    if (line.startsWith('DA:')) {
      final rest = line.substring(3);
      final comma = rest.indexOf(',');
      if (comma <= 0) continue;
      final lineNo = int.tryParse(rest.substring(0, comma));
      final hit = int.tryParse(rest.substring(comma + 1));
      if (lineNo == null || hit == null) continue;

      final t = totals[current]!;
      totals[current] = (hit: t.hit + (hit > 0 ? 1 : 0), total: t.total + 1);
      if (hit == 0) uncovered[current]!.add(lineNo);
    }
  }

  int allHit = 0;
  int allTotal = 0;
  for (final e in totals.values) {
    allHit += e.hit;
    allTotal += e.total;
  }

  final pct = allTotal == 0 ? 100.0 : (allHit / allTotal) * 100.0;
  stdout.writeln('TOTAL: $allHit/$allTotal (${pct.toStringAsFixed(2)}%)');

  final entries = totals.entries.toList()
    ..sort((a, b) {
      final au = uncovered[a.key]!.length;
      final bu = uncovered[b.key]!.length;
      return bu.compareTo(au);
    });

  for (final e in entries) {
    final path = e.key;
    final u = uncovered[path]!;
    if (u.isEmpty) continue;
    final t = e.value;
    final fpct = t.total == 0 ? 100.0 : (t.hit / t.total) * 100.0;
    stdout.writeln('${u.length} uncovered, ${t.hit}/${t.total} (${fpct.toStringAsFixed(2)}%): $path');
    final sample = u.take(30).toList();
    stdout.writeln('  lines: ${sample.join(', ')}${u.length > sample.length ? ', ...' : ''}');
  }
}

