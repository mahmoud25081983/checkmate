import 'package:flutter/material.dart';
import 'package:checkmate/schemas/item.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // Import Timer from dart:async

import '../../services/realm_service.dart';

class ToggleStatusDialog extends StatefulWidget {
  final Item item;

  const ToggleStatusDialog({Key? key, required this.item}) : super(key: key);

  @override
  ToggleStatusDialogState createState() => ToggleStatusDialogState();
}

class ToggleStatusDialogState extends State<ToggleStatusDialog> {
  int _counter = 10; // Initial countdown timer value
  Timer? _timer;
  bool confirmation = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      if (_counter == 0) {
        timer.cancel();
        Navigator.of(context).pop(); 
        // Automatically confirm after timer ends
        // Optionally, you can call your toggleStatus function here
        // itemService.toggleStatus(widget.item, itemService.currentAccount!);
      } else {
        setState(() {
          _counter--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemService = Provider.of<ItemService>(context, listen: false);

    return AlertDialog(
      title: Text(widget.item.isDone
          ? "Mission Not Done Yet"
          : confirmation
              ? "Confirm Mission Done"
              : 'Mission Done'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(widget.item.isDone
              ? "Please Confirm Mission Not Done Yet"
              : confirmation
                  ? 'Please Confirm ${widget.item.text} Mission Done befor Counter end?'
                  : 'Are you sure you Done ${widget.item.text} Mission?'),
          const SizedBox(height: 16),
          if (confirmation)
            Text(
              'Timer: $_counter seconds',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            _timer?.cancel(); // Cancel the timer if cancel is pressed
            Navigator.of(context).pop();
          },
        ),
        widget.item.isDone
            ? TextButton(
                child: const Text('Yes'),
                onPressed: () {
                  itemService.toggleStatus(
                      widget.item, itemService.currentAccount!);
                  _timer?.cancel(); // Cancel the timer if Yes is pressed
                  Navigator.of(context).pop();
                },
              )
            : confirmation
                ? TextButton(
                    child: const Text('Yes'),
                    onPressed: () {
                      itemService.toggleStatus(
                          widget.item, itemService.currentAccount!);
                      _timer?.cancel(); // Cancel the timer if Yes is pressed
                      Navigator.of(context).pop();
                    },
                  )
                : TextButton(
                    child: const Text('Yes'),
                    onPressed: () {
                      if (confirmation == false) {
                        confirmation = !confirmation;
                      }

                      if (confirmation) {
                        setState(() {
                          _startTimer();
                        });
                      }
                    },
                  )
      ],
    );
  }
}

Future<void> showToggleStatusDialog(BuildContext context, Item item) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return ToggleStatusDialog(item: item);
    },
  );
}
