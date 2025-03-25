import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Car Loan'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //Declare local variables
  double _loanAmount = 0.0;
  double _netIncome = 0.0;
  double _interestRate = 0.0;
  int _loanPeriod = 1;
  bool _hasGuarantor = false;
  int _carType = 1; //1 = New, 2 = Used
  double _repaymentAmount = 0.0;
  String _repaymentOutput = '';
  final _years = [1,2,3,4,5,6,7,8,9];
//Controller
  final loanAmountCtrl = TextEditingController();
  final netIncomeCtrl = TextEditingController();
  final interestRateCtrl = TextEditingController();
//Set focus to a specific widget
  final _myFocusNode = FocusNode();
//Format output with the currency symbol of Malaysia
  final myCurrency = intl.NumberFormat('#,##0.00', 'ms_MY');
//Form controller - manages the overall form state
  final _formKey = GlobalKey<FormState>();

  void myAlertDialog(){
    AlertDialog eligibilityAlertDialog = AlertDialog(
      title: const Text('Eligibility'),
      content: const Text('You are not eligible for this loan. '
          'Get a guarantor to proceed'),
      actions: [
        TextButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: const Text('Ok')),
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context){
          return eligibilityAlertDialog;
        });
  }

  void _calculateRepayment(){
    _loanAmount = double.parse(loanAmountCtrl.text);
    _netIncome = double.parse(netIncomeCtrl.text);
    _interestRate = double.parse(interestRateCtrl.text);
    var interest = _loanAmount * _loanPeriod * (_interestRate/100);
    _repaymentAmount = (_loanAmount + interest) / (_loanPeriod * 12);
    bool eligible = _netIncome * 0.3 >= _repaymentAmount;
    if(eligible || _hasGuarantor){
      setState(() {
        _repaymentOutput = 'Repayment Amount : '
            '${myCurrency.currencySymbol} '
            '${myCurrency.format(_repaymentAmount)} '
            '\n '
            'Eligibility : ${eligible? 'Eligible': 'Not Eligible'}';
      });
    }else{
      myAlertDialog();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
    body: Form(
      key: _formKey,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Loan Amount',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: loanAmountCtrl,
            focusNode: _myFocusNode,
            validator: (value){
              if(value == null || value.isEmpty){
                return 'Please enter loan amount';
              }
              return null;
              },
          ),

    TextFormField(
    decoration: const InputDecoration(
    labelText: 'Net Income',
    ),
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    controller: netIncomeCtrl,
    validator: (value){
    if(value == null || value.isEmpty){
    return 'Please enter net income';
    }
    return null;
    },
    ),

          DropdownButtonFormField(
            value: _loanPeriod,
            items: _years.map((int item){
              return DropdownMenuItem(
                value: item,
                child: Text('$item year(s)'),
              );
            }).toList(),
            onChanged: (int? item){
              setState(() {
                _loanPeriod = item!;
              });
            },
            validator: (value){
              if(value == 0){
                return 'Please select an option';
              }
              return null;
            },
            decoration: const InputDecoration(
                labelText: 'Select loan period (year)'
            ),
          ),
    TextFormField(
    keyboardType: const TextInputType.numberWithOptions(
    decimal: true,
    signed: false
    ),
    inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
    ],
    decoration: const InputDecoration(
    labelText: 'Interest Rate (%)'
    ),
      controller: interestRateCtrl,
      validator: (value){
        if(value == null || value.isEmpty){
          return 'Please enter interest rate';
        }
        return null;
      },
    ),
          CheckboxListTile(
              value: _hasGuarantor,
              title: const Text('I have a guarantor'),
              onChanged: (value) {
                setState(() {
                  _hasGuarantor = value!;
                });
              }),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Car Type', textDirection: TextDirection.ltr,),
          ),
          RadioListTile(
              title: const Text('New'),
              value: 1, //New car
              groupValue: _carType,
              onChanged: (value){
                setState(() {
                  _carType = value!;
                });
              }),
          RadioListTile(
              title: const Text('Used'),
              value: 2, //Used car
              groupValue: _carType,
              onChanged: (value){
                setState(() {
                  _carType = value!;
                });
              }),
          // Display repayment amount
          Text(_repaymentOutput),
          ElevatedButton(
              onPressed: () {
// Validate returns true if the form is valid, or false otherwise. e
                if(_formKey.currentState!.validate()){
// If the form is valid e
                  if(validInterest(_carType)){
                    _calculateRepayment();
                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid interest rate'),)
                    );
                  }
                }
              },
              child: const Text('Calculate')
          ),
      ],
         ),
       ),
      ),
    );
  }
}
