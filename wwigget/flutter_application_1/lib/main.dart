import 'package:flutter/material.dart';
import 'game.dart'; 

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wordle Clone',
      home: WordleScreen(),
    );
  }
}

class WordleScreen extends StatefulWidget {
  const WordleScreen({super.key});

  @override
  State<WordleScreen> createState() => _WordleScreenState();
}

class _WordleScreenState extends State<WordleScreen> {
  final Game _game = Game();
  
  // Biến lưu trữ từ đang được gõ trên hàng hiện tại
  String _currentGuess = '';

  void _onKeyPressed(String key) {
    // Nếu game đã kết thúc (thắng hoặc thua) thì không cho gõ nữa
    if (_game.didWin || _game.didLose) return;

    // Dùng setState để báo cho Flutter biết giao diện cần được vẽ lại
    setState(() {
      if (key == 'DEL') {
        // Xóa ký tự cuối cùng nếu có
        if (_currentGuess.isNotEmpty) {
          _currentGuess = _currentGuess.substring(0, _currentGuess.length - 1);
        }
      } else if (key == 'ENTER') {
        // Chỉ cho phép Enter khi đã gõ đủ 5 chữ cái
        if (_currentGuess.length == 5) {
          // Kiểm tra xem từ này có trong từ điển của game.dart không
          if (_game.isLegalGuess(_currentGuess.toLowerCase())) {
            _game.guess(_currentGuess.toLowerCase()); // Chốt đáp án
            _currentGuess = ''; // Xóa trắng để chuẩn bị gõ hàng tiếp theo
            
            // Hiện thông báo nếu thắng hoặc thua
            if (_game.didWin) {
              _showMessage("Chúc mừng! Bạn đã đoán đúng.");
            } else if (_game.didLose) {
              _showMessage("Game over! Từ đúng là: ${_game.hiddenWord}");
            }
          } else {
            // Báo lỗi nếu nhập từ linh tinh không có nghĩa
            _showMessage("Từ này không có trong từ điển!");
          }
        }
      } else {
        // Nếu là chữ cái bình thường, thêm vào từ đang gõ (tối đa 5 chữ)
        if (_currentGuess.length < 5) {
          _currentGuess += key;
        }
      }
    });
  }

  // Hàm tiện ích để hiển thị thông báo nhỏ (SnackBar) dưới đáy màn hình
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Wordle'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // Dùng List.generate để tạo 5 hàng
                children: List.generate(5, (rowIndex) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // Mỗi hàng tạo 5 ô
                    children: List.generate(5, (colIndex) {
                      String letter = '';
                      HitType hitType = HitType.none;

                      // Xác định hàng hiện tại đang chơi
                      int activeRow = _game.activeIndex;

                      if (rowIndex < activeRow || activeRow == -1) {
                        // HÀNG ĐÃ ĐOÁN: Lấy dữ liệu từ logic game để tô màu
                        letter = _game.guesses[rowIndex][colIndex].char;
                        hitType = _game.guesses[rowIndex][colIndex].type;
                      } else if (rowIndex == activeRow) {
                        // HÀNG ĐANG GÕ: Hiển thị các chữ cái từ _currentGuess
                        if (colIndex < _currentGuess.length) {
                          letter = _currentGuess[colIndex];
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Tile(letter, hitType),
                      );
                    }),
                  );
                }),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0, left: 8.0, right: 8.0),
            child: Keyboard(onKeyPressed: _onKeyPressed),
          ),
        ],
      ),
    );
  }
}

class Tile extends StatelessWidget {
  const Tile(this.letter, this.hitType, {super.key});

  final String letter;
  final HitType hitType;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        border: Border.all(
            color: hitType == HitType.none && letter.isNotEmpty 
                ? Colors.grey.shade600 // Đậm hơn chút nếu có chữ nhưng chưa enter
                : Colors.grey.shade400, 
            width: 2),
        borderRadius: BorderRadius.circular(8),
        color: switch (hitType) {
          HitType.hit => Colors.green,
          HitType.partial => Colors.yellow.shade700,
          HitType.miss => Colors.grey.shade600,
          _ => Colors.white,
        },
      ),
      child: Center(
        child: Text(
          letter.toUpperCase(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: hitType == HitType.none ? Colors.black87 : Colors.white,
          ),
        ),
      ),
    );
  }
}

class Keyboard extends StatelessWidget {
  const Keyboard({super.key, required this.onKeyPressed});
  final void Function(String) onKeyPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow(['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P']),
        _buildRow(['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L']),
        _buildRow(['ENTER', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', 'DEL']),
      ],
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((key) {
        bool isSpecialKey = key == 'ENTER' || key == 'DEL';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
          child: InkWell(
            onTap: () => onKeyPressed(key),
            child: Container(
              height: 45,
              width: isSpecialKey ? 60 : 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  key,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isSpecialKey ? 12 : 16,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}