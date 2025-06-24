import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';

class VirtualKeyboardScreen extends StatefulWidget {
  const VirtualKeyboardScreen({Key? key}) : super(key: key);

  @override
  State<VirtualKeyboardScreen> createState() => _VirtualKeyboardScreenState();
}

class _VirtualKeyboardScreenState extends State<VirtualKeyboardScreen> {
  final TextEditingController _textController = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isCapsLockEnabled = false;
  bool _isSymbolsEnabled = false;
  double _keySize = 50.0;
  double _keySpacing = 4.0;
  double _textSize = 18.0;
  double _keyboardOpacity = 1.0;
  Color _keyboardTheme = Colors.deepPurple;
  bool _isSpeaking = false;

  // Haptic feedback
  final _vibration = const Duration(milliseconds: 50);

  // Keyboard layouts
  static const List<List<String>> _lowercaseLayout = [
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
    ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
    ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';'],
    ['z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/'],
  ];

  static const List<List<String>> _uppercaseLayout = [
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ':'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M', '<', '>', '?'],
  ];

  static const List<List<String>> _symbolsLayout = [
    ['!', '@', '#', '\$', '%', '^', '&', '*', '(', ')'],
    ['~', '`', '{', '}', '[', ']', '-', '_', '+', '='],
    ['|', '\\', '"', '\'', '<', '>', '€', '£', '¥', '•'],
    ['§', '¶', '©', '®', '™', '℃', '℉', '♠', '♣', '☺'],
  ];

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _textController.addListener(_onTextChanged);
  }

  Future<void> _initializeTts() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _flutterTts.setCompletionHandler(() {
        setState(() => _isSpeaking = false);
      });
    } catch (e) {
      debugPrint('TTS initialization error: $e');
    }
  }

  void _onTextChanged() {
    // You can add any text change listeners here
  }

  void _addText(String text) async {
    await _vibrate();
    final currentText = _textController.text;
    int cursorPosition = _textController.selection.isValid
        ? _textController.selection.start
        : currentText.length;

    cursorPosition = cursorPosition.clamp(0, currentText.length);

    final newText = currentText.substring(0, cursorPosition) +
        text +
        currentText.substring(cursorPosition);

    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorPosition + text.length),
    );
  }

  void _backspace() async {
    await _vibrate();
    final currentText = _textController.text;
    if (currentText.isEmpty) return;

    int cursorPosition = _textController.selection.isValid
        ? _textController.selection.start
        : currentText.length;

    cursorPosition = cursorPosition.clamp(0, currentText.length);
    if (cursorPosition == 0) return;

    final newText = currentText.substring(0, cursorPosition - 1) +
        currentText.substring(cursorPosition);

    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorPosition - 1),
    );
  }

  void _clearText() async {
    await _vibrate();
    _textController.clear();
  }

  void _toggleCapsLock() async {
    await _vibrate();
    setState(() {
      _isCapsLockEnabled = !_isCapsLockEnabled;
      _isSymbolsEnabled = false;
    });
  }

  void _toggleSymbols() async {
    await _vibrate();
    setState(() {
      _isSymbolsEnabled = !_isSymbolsEnabled;
      if (_isSymbolsEnabled) _isCapsLockEnabled = false;
    });
  }

  Future<void> _speak() async {
    try {
      if (_textController.text.isNotEmpty) {
        setState(() => _isSpeaking = true);
        await _flutterTts.speak(_textController.text);
      } else {
        // Play an alert sound
        await SystemSound.play(SystemSoundType.alert);

        // Show snackbar
        if (mounted && context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Please enter some text to speak'),
                ],
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.all(8),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('TTS speak error: $e');
      setState(() => _isSpeaking = false);
    }
  }

  Future<void> _vibrate() async {
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    List<List<String>> activeLayout;
    if (_isSymbolsEnabled) {
      activeLayout = _symbolsLayout;
    } else if (_isCapsLockEnabled) {
      activeLayout = _uppercaseLayout;
    } else {
      activeLayout = _lowercaseLayout;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ALS Virtual Keyboard',
          style: TextStyle(color: Colors.white), // Title text color
        ),
        backgroundColor: _keyboardTheme,
        iconTheme: const IconThemeData(
            color: Colors.white), // Icon color (back, settings)

        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Text display area
            _buildTextDisplay(),
            // Keyboard area
            Expanded(
              child: Opacity(
                opacity: _keyboardOpacity,
                child: SingleChildScrollView(
                  child: _buildKeyboard(activeLayout),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextDisplay() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Text Output',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${_textController.text.length} chars',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey[300]),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _textController,
              readOnly: true,
              maxLines: 5,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Your text will appear here...',
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
              style: TextStyle(fontSize: _textSize),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.volume_up,
                    color: _isSpeaking ? _keyboardTheme : Colors.grey,
                  ),
                  onPressed: _isSpeaking ? null : _speak,
                  tooltip: 'Speak text',
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey),
                  onPressed: _textController.text.isEmpty ? null : _clearText,
                  tooltip: 'Clear text',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboard(List<List<String>> layout) {
    return Column(
      children: [
        // Main keyboard rows
        for (final row in layout)
          Padding(
            padding: EdgeInsets.symmetric(vertical: _keySpacing / 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final key in row)
                  Expanded(
                    child: _buildKeyButton(
                      key: key,
                      width: null, // Remove fixed width to allow flexibility
                      onPressed: () => _addText(key),
                    ),
                  ),
              ],
            ),
          ),

        // First function row
        Padding(
          padding: EdgeInsets.symmetric(vertical: _keySpacing / 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 15,
                child: _buildKeyButton(
                  width: null,
                  onPressed: _toggleCapsLock,
                  backgroundColor: _isCapsLockEnabled ? _keyboardTheme : null,
                  child: Icon(
                    Icons.arrow_upward,
                    color: _isCapsLockEnabled ? Colors.white : _keyboardTheme,
                  ),
                ),
              ),
              Expanded(
                flex: 40,
                child: _buildKeyButton(
                  key: 'Space',
                  width: null,
                  onPressed: () => _addText(' '),
                ),
              ),
              Expanded(
                flex: 15,
                child: _buildKeyButton(
                  key: '&123',
                  width: null,
                  onPressed: _toggleSymbols,
                  backgroundColor: _isSymbolsEnabled ? _keyboardTheme : null,
                  textColor: _isSymbolsEnabled ? Colors.white : _keyboardTheme,
                ),
              ),
              Expanded(
                flex: 15,
                child: _buildKeyButton(
                  width: null,
                  onPressed: _backspace,
                  child: Icon(Icons.backspace, color: _keyboardTheme),
                ),
              ),
            ],
          ),
        ),

        // Second function row
        Padding(
          padding: EdgeInsets.symmetric(vertical: _keySpacing / 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _buildKeyButton(
                  key: 'Enter',
                  width: null,
                  onPressed: () => _addText('\n'),
                  backgroundColor: _keyboardTheme.withOpacity(0.8),
                  textColor: Colors.white,
                ),
              ),
              Expanded(
                child: _buildKeyButton(
                  width: null,
                  onPressed: _textController.text.isEmpty ? null : _speak,
                  backgroundColor:
                      _textController.text.isEmpty ? Colors.grey : Colors.green,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.volume_up,
                        color: Colors.white,
                        size: _textSize,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Speak',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _textSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeyButton({
    String? key,
    double? width,
    required VoidCallback? onPressed,
    Color? backgroundColor,
    Color? textColor,
    Widget? child,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _keySpacing / 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: width,
        height: _keySize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            if (onPressed != null)
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? Colors.white,
            foregroundColor: textColor ?? Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: Colors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: child ??
                Text(
                  key ?? '',
                  style: TextStyle(
                    fontSize: _textSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
          ),
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    double tempKeySize = _keySize;
    double tempKeySpacing = _keySpacing;
    double tempTextSize = _textSize;
    double tempKeyboardOpacity = _keyboardOpacity;
    Color tempKeyboardTheme = _keyboardTheme;

    final List<Color> themeColors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.red,
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Keyboard Settings'),
              content: SizedBox(
                width: 300,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Key Size'),
                      Slider(
                        value: tempKeySize,
                        min: 30.0,
                        max: 70.0,
                        divisions: 8,
                        label: tempKeySize.round().toString(),
                        onChanged: (value) =>
                            setDialogState(() => tempKeySize = value),
                      ),
                      const SizedBox(height: 16),
                      const Text('Key Spacing'),
                      Slider(
                        value: tempKeySpacing,
                        min: 2.0,
                        max: 10.0,
                        divisions: 8,
                        label: tempKeySpacing.round().toString(),
                        onChanged: (value) =>
                            setDialogState(() => tempKeySpacing = value),
                      ),
                      const SizedBox(height: 16),
                      const Text('Text Size'),
                      Slider(
                        value: tempTextSize,
                        min: 14.0,
                        max: 30.0,
                        divisions: 8,
                        label: tempTextSize.round().toString(),
                        onChanged: (value) =>
                            setDialogState(() => tempTextSize = value),
                      ),
                      const SizedBox(height: 16),
                      const Text('Keyboard Opacity'),
                      Slider(
                        value: tempKeyboardOpacity,
                        min: 0.5,
                        max: 1.0,
                        divisions: 5,
                        label:
                            '${(tempKeyboardOpacity * 100).round().toString()}%',
                        onChanged: (value) =>
                            setDialogState(() => tempKeyboardOpacity = value),
                      ),
                      const SizedBox(height: 16),
                      const Text('Theme Color'),
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: themeColors.length,
                          itemBuilder: (context, index) {
                            final color = themeColors[index];
                            return GestureDetector(
                              onTap: () => setDialogState(() {
                                tempKeyboardTheme = color;
                              }),
                              child: Container(
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: tempKeyboardTheme == color
                                        ? Colors.black
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _keyboardTheme,
                  ),
                  onPressed: () {
                    setState(() {
                      _keySize = tempKeySize;
                      _keySpacing = tempKeySpacing;
                      _textSize = tempTextSize;
                      _keyboardOpacity = tempKeyboardOpacity;
                      _keyboardTheme = tempKeyboardTheme;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _flutterTts.stop();
    super.dispose();
  }
}
