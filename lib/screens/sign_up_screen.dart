import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tinder_binder/screens/profile_picture_update_screen.dart';

import '../constants/constants.dart';
import '../dialogs/common_dialogs.dart';
import '../helpers/app_localizations.dart';
import '../models/user_model.dart';
import '../widgets/default_button.dart';
import '../widgets/image_source_sheet.dart';
import '../widgets/processing.dart';
import '../widgets/show_scaffold_msg.dart';
import '../widgets/svg_icon.dart';
import '../widgets/terms_of_service_row.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Variables
  final _formKey = GlobalKey<FormState>();
  final _familyFormKey = GlobalKey<FormState>();
  final _basicInfoFormKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _nameController = TextEditingController();
  final _schoolController = TextEditingController();
  final _jobController = TextEditingController();
  final _bioController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _gothraController = TextEditingController();
  final _noOfBrothers = TextEditingController();
  final _noOfSisters = TextEditingController();
  final _institueName = TextEditingController();
  final _companyName = TextEditingController();

  /// User Birthday info
  int _userBirthDay = 0;
  int _userBirthMonth = 0;
  int _userBirthYear = DateTime.now().year;
  // End
  DateTime _initialDateTime = DateTime.now();
  String? _birthday;
  File? _imageFile;
  bool _agreeTerms = false;
  String? _selectedGender;
  String? selectedReligion;
  String? selectedCaste;
  String? selectedSubCaste;
  String? gothra;
  String? selectedState;
  String? selectedVillage;
  int? noOfBrothers;
  int? noOfSisters;
  String? selectedMotherTongue;
  String? selectedAccountCreatedBy;
  String? selectedBodyType;
  bool? foodingHabit;
  bool? drinkingHabit;
  bool? smokingHabit;
  String? employedIn;
  String? income;
  String? highestEducation;
  List<String> _genders = ['Male', 'Female'];
  List<String> _religion = ['Hindu'];
  List<String> _accountCreatedBy = [
    'Self',
    'Son',
    'Daughter',
    'Brother',
    'Sister',
    'Parents',
    'Friend',
    'Relatives',
    'Other'
  ];
  List<String> _motherTongue = ['Bengali', 'Kudmali', 'Odia'];
  List<String> _bodyType = ['Slim', 'Average', 'Athletic', 'Heavy'];
  List<String> _foodingHabit = ['Yes', 'No'];
  List<String> _drinkingHabit = ['Yes', 'No'];
  List<String> _smokingHabit = ['Yes', 'No'];
  List<String> _highestEducation = ['UG', 'PG'];
  List<String> _employedIn = [
    'Private',
    'Defence',
    'Government',
    'Business',
    'Self-employed',
    'Not Working'
  ];
  List<String> _income = [
    '0',
    '0-3 LPA',
    '3-6 LPA',
    '6-9 LPA',
    '9-12 LPA',
    '12-15 LPA',
    '15-18 LPA',
    '18-21 LPA',
    '21-24 LPA',
    '25+ LPA'
  ];
  List<String> _caste = ['Kurmi/Kudmi'];
  List<String> _subCaste = ['Mahato'];
  List<String> _ancestralState = ['Jharkhand', 'Bengal', 'Odisha'];
  List<String> _ancestralVillage = []; //TODO: add village list
  late AppLocalizations _i18n;

  int currentWizardIndex = 0;

  bool? isMaleSelected = false;
  bool? isFemaleSelected = false;

  /// Set terms
  void _setAgreeTerms(bool value) {
    setState(() {
      _agreeTerms = value;
    });
  }

  /// Get image from camera / gallery
  void _getImage(BuildContext context) async {
    await showModalBottomSheet(
        context: context,
        builder: (context) => ImageSourceSheet(
              onImageSelected: (image) {
                if (image != null) {
                  setState(() {
                    _imageFile = image;
                  });
                  // close modal
                  Navigator.of(context).pop();
                }
              },
            ));
  }

  void _updateUserBithdayInfo(DateTime date) {
    setState(() {
      // Update the inicial date
      _initialDateTime = date;
      // Set for label
      _birthday = date.toString().split(' ')[0];
      // User birthday info
      _userBirthDay = date.day;
      _userBirthMonth = date.month;
      _userBirthYear = date.year;
    });
  }

  // Get Date time picker app locale
  DateTimePickerLocale _getDatePickerLocale() {
    // Inicial value
    DateTimePickerLocale _locale = DateTimePickerLocale.en_us;

    // Handle your Supported Languages here
    SUPPORTED_LOCALES.forEach((Locale locale) {
      switch (locale.languageCode) {
        case 'en': // English
          _locale = DateTimePickerLocale.en_us;
          break;
        case 'es': // Spanish
          _locale = DateTimePickerLocale.es;
          break;
      }
    });

    return _locale;
  }

  /// Display date picker.
  void _showDatePicker() {
    DatePicker.showDatePicker(
      context,
      onMonthChangeStartWithFirstDate: true,
      pickerTheme: DateTimePickerTheme(
        showTitle: true,
        confirm: Text(_i18n.translate('DONE'),
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Theme.of(context).primaryColor)),
      ),
      minDateTime: DateTime(1920, 1, 1),
      maxDateTime: DateTime.now(),
      initialDateTime: _initialDateTime,
      dateFormat: 'yyyy-MMMM-dd', // Date format
      locale: _getDatePickerLocale(), // Set your App Locale here
      onClose: () => print("----- onClose -----"),
      onCancel: () => print('onCancel'),
      onChange: (dateTime, List<int> index) {
        // Get birthday info
        _updateUserBithdayInfo(dateTime);
      },
      onConfirm: (dateTime, List<int> index) {
        // Get birthday info
        _updateUserBithdayInfo(dateTime);
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    /// Initialization
    _i18n = AppLocalizations.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xff010b29),
          title: currentWizardIndex == 0
              ? Text(
                  'User Info',
                  style: TextStyle(color: Color(0xffff9c9c)),
                )
              : currentWizardIndex == 1
                  ? Text(
                      'Basic Info',
                      style: TextStyle(color: Colors.black),
                    )
                  : currentWizardIndex == 2
                      ? Text(
                          'Family Info',
                          style: TextStyle(color: Colors.black),
                        )
                      : Text(
                          'Signup',
                          style: TextStyle(color: Colors.black),
                        )),
      body: ScopedModelDescendant<UserModel>(
          builder: (context, child, userModel) {
        /// Check loading status
        if (userModel.isLoading) return Processing();
        switch (currentWizardIndex) {
          case (0):
            return UserDataSection();
          case (1):
            return BasicInfoSection();
          case (2):
            return FamilyDetailsSection();
          default:
            return UserDataSection();
        }
      }),
    );
  }

  Widget BasicInfoSection() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Form(
            key: _basicInfoFormKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SvgPicture.asset(
                    "assets/icons/basic_info_2.svg",
                    width: 200,
                    height: 200,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField<String>(
                    items: _accountCreatedBy.map((createdBy) {
                      return new DropdownMenuItem(
                          value: createdBy,
                          child: Text('${createdBy.toString()}'));
                    }).toList(),
                    hint: Text('Account Created By'),
                    onChanged: (createdBy) {
                      setState(() {
                        selectedAccountCreatedBy = createdBy;
                      });
                    },
                    validator: (String? value) {
                      if (value == null) {
                        return "Please select your relationship with the user";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField<String>(
                    items: _motherTongue.map((motherTongue) {
                      return new DropdownMenuItem(
                          value: motherTongue,
                          child: Text('${motherTongue.toString()}'));
                    }).toList(),
                    hint: Text('Mother Tongue'),
                    onChanged: (motherTongue) {
                      setState(() {
                        selectedMotherTongue = motherTongue;
                      });
                    },
                    validator: (String? value) {
                      if (value == null) {
                        return "Please select your mother tongue";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField<String>(
                    items: _bodyType.map((bodyType) {
                      return new DropdownMenuItem(
                          value: bodyType,
                          child: Text('${bodyType.toString()}'));
                    }).toList(),
                    hint: Text('Body Type'),
                    onChanged: (bodyType) {
                      setState(() {
                        selectedBodyType = bodyType;
                      });
                    },
                    validator: (String? value) {
                      if (value == null) {
                        return "Please select body type";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField<String>(
                    items: _foodingHabit.map((foodingHabit) {
                      return new DropdownMenuItem(
                          value: foodingHabit,
                          child: Text('${foodingHabit.toString()}'));
                    }).toList(),
                    hint: Text('Fooding Habit'),
                    onChanged: (foodHabit) {
                      setState(() {
                        if (foodHabit?.toLowerCase() == "yes") {
                          foodingHabit = true;
                        } else {
                          foodingHabit = false;
                        }
                      });
                    },
                    validator: (String? value) {
                      if (value == null) {
                        return "Please select user\'s fooding habit";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField<String>(
                    items: _smokingHabit.map((smokingHabit) {
                      return new DropdownMenuItem(
                          value: smokingHabit,
                          child: Text('${smokingHabit.toString()}'));
                    }).toList(),
                    hint: Text('Smoking Habit'),
                    onChanged: (smokeHabit) {
                      setState(() {
                        if (smokeHabit?.toLowerCase() == "yes") {
                          smokingHabit = true;
                        } else {
                          smokingHabit = false;
                        }
                      });
                    },
                    validator: (String? value) {
                      if (value == null) {
                        return "Please select user\'s smoking habit";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField<String>(
                    items: _drinkingHabit.map((drinkingHabit) {
                      return new DropdownMenuItem(
                          value: drinkingHabit,
                          child: Text('${drinkingHabit.toString()}'));
                    }).toList(),
                    hint: Text('Drinking Habit'),
                    onChanged: (drinkHabit) {
                      setState(() {
                        if (drinkHabit?.toLowerCase() == "yes") {
                          drinkingHabit = true;
                        } else {
                          drinkingHabit = false;
                        }
                      });
                    },
                    validator: (String? value) {
                      if (value == null) {
                        return "Please select user\'s drinking habit";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField<String>(
                    items: _highestEducation.map((highestEducation) {
                      return new DropdownMenuItem(
                          value: highestEducation,
                          child: Text('${highestEducation.toString()}'));
                    }).toList(),
                    hint: Text('Highest Education'),
                    onChanged: (highEdu) {
                      setState(() {
                        highestEducation = highEdu;
                      });
                    },
                    validator: (String? value) {
                      if (value == null) {
                        return "Please select user\'s highest education";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    controller: _institueName,
                    decoration: InputDecoration(
                      labelText: 'Institute\'s Name',
                      hintText: 'Enter your institute\'s name',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      prefixIcon: Icon(
                        Icons.book_outlined,
                        color: Colors.redAccent,
                      ),
                    ),
                    validator: (name) {
                      // Basic validation
                      if (name?.isEmpty ?? false) {
                        return "Please enter your institute\'s name";
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField<String>(
                    items: _employedIn.map((employedIn) {
                      return new DropdownMenuItem(
                          value: employedIn,
                          child: Text('${employedIn.toString()}'));
                    }).toList(),
                    hint: Text('Employed In'),
                    onChanged: (employedIn) {
                      setState(() {
                        employedIn = employedIn;
                      });
                    },
                    validator: (String? value) {
                      if (value == null) {
                        return "Please select details about user\'s employment";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    controller: _companyName,
                    decoration: InputDecoration(
                      labelText: 'Company\'s Name',
                      hintText: 'Enter your company\'s name',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      prefixIcon: Icon(
                        Icons.work_outline,
                        color: Colors.redAccent,
                      ),
                    ),
                    validator: (name) {
                      // Basic validation
                      if (name?.isEmpty ?? false) {
                        return "Please enter your company\'s name";
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField<String>(
                    items: _income.map((income) {
                      return new DropdownMenuItem(
                          value: income, child: Text('${income.toString()}'));
                    }).toList(),
                    hint: Text('Income'),
                    onChanged: (incomeAmt) {
                      setState(() {
                        income = incomeAmt;
                      });
                    },
                    validator: (String? value) {
                      if (value == null) {
                        return "Please select details about user\'s income";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      currentWizardIndex != 0
                          ? SizedBox(
                              width: MediaQuery.of(context).size.width / 3,
                              child: DefaultButton(
                                // child: Text(_i18n.translate("CREATE_ACCOUNT"),
                                child: Text('Previous',
                                    style: TextStyle(fontSize: 18)),
                                onPressed: () {
                                  setState(() {
                                    currentWizardIndex -= 1;
                                  });
                                },
                              ),
                            )
                          : SizedBox(),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3,
                        child: DefaultButton(
                          // child: Text(_i18n.translate("CREATE_ACCOUNT"),
                          child: Text('Next', style: TextStyle(fontSize: 18)),
                          onPressed: () {
                            setState(() {
                              if (_basicInfoFormKey.currentState!.validate()) {
                                _basicInfoFormKey.currentState!.save();
                                currentWizardIndex += 1;
                              } else {
                                showScaffoldMessage(
                                    context: context,
                                    message:
                                        'Please fill all the required fields');
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget FamilyDetailsSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Form(
            key: _familyFormKey,
            child: Column(
              children: [
                SvgPicture.asset(
                  "assets/icons/wedding.svg",
                  width: 200,
                  height: 200,
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    controller: _fatherNameController,
                    decoration: InputDecoration(
                        labelText: 'Father\'s Name',
                        hintText: 'Enter your father\'s name',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SvgIcon("assets/icons/user_icon.svg"),
                        )),
                    validator: (name) {
                      // Basic validation
                      if (name?.isEmpty ?? false) {
                        return "Please enter your father\'s name";
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    controller: _motherNameController,
                    decoration: InputDecoration(
                        labelText: 'Mother\'s Name',
                        hintText: 'Enter your mother\'s name',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SvgIcon("assets/icons/user_icon.svg"),
                        )),
                    validator: (name) {
                      // Basic validation
                      if (name?.isEmpty ?? false) {
                        return "Please enter your mother\'s name";
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField<String>(
                    items: _religion.map((religion) {
                      return new DropdownMenuItem(
                          value: religion,
                          child: Text('${religion.toString()}'));
                    }).toList(),
                    hint: Text('Select religion'),
                    onChanged: (religion) {
                      setState(() {
                        selectedReligion = religion;
                      });
                    },
                    validator: (String? value) {
                      if (value == null) {
                        return "Please select your religion";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField<String>(
                    items: _caste.map((caste) {
                      return new DropdownMenuItem(
                          value: caste, child: Text('${caste.toString()}'));
                    }).toList(),
                    hint: Text('Select caste'),
                    onChanged: (caste) {
                      setState(() {
                        selectedCaste = caste;
                      });
                    },
                    validator: (String? value) {
                      if (value == null) {
                        return "Please select your caste";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField<String>(
                    items: _subCaste.map((subCaste) {
                      return new DropdownMenuItem(
                          value: subCaste,
                          child: Text('${subCaste.toString()}'));
                    }).toList(),
                    hint: Text('Select sub-caste'),
                    onChanged: (subCaste) {
                      setState(() {
                        selectedSubCaste = subCaste;
                      });
                    },
                    validator: (String? value) {
                      if (value == null) {
                        return "Please select your sub-caste";
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    controller: _gothraController,
                    decoration: InputDecoration(
                        labelText: 'Gothra',
                        hintText: 'Enter your gothra',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SvgIcon("assets/icons/calendar_icon.svg"),
                        )),
                    validator: (gothra) {
                      // Basic validation
                      if (gothra?.isEmpty ?? false) {
                        return "Please enter your gothra";
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField<String>(
                    items: _ancestralState.map((state) {
                      return new DropdownMenuItem(
                          value: state, child: Text('${state.toString()}'));
                    }).toList(),
                    hint: Text('Select ancestral state'),
                    onChanged: (state) {
                      setState(() {
                        selectedState = state;
                      });
                    },
                    validator: (String? value) {
                      if (value == null) {
                        return "Please select your ancestral state";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField<String>(
                    items: _ancestralVillage.map((village) {
                      return new DropdownMenuItem(
                          value: village, child: Text('${village.toString()}'));
                    }).toList(),
                    hint: Text('Select ancestral village'),
                    onChanged: (village) {
                      setState(() {
                        selectedVillage = village;
                      });
                    },
                    validator: (String? value) {
                      if (value == null) {
                        return "Please select your ancestral village";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    controller: _noOfBrothers,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: 'No. of Brothers',
                        hintText: 'Enter your number of brothers',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SvgIcon("assets/icons/user_icon.svg"),
                        )),
                    validator: (name) {
                      // Basic validation
                      if (name?.isEmpty ?? false) {
                        return "Please enter your number of brothers";
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    controller: _noOfSisters,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: 'No. of Sisters',
                        hintText: 'Enter your number of sisters',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SvgIcon("assets/icons/user_icon.svg"),
                        )),
                    validator: (name) {
                      // Basic validation
                      if (name?.isEmpty ?? false) {
                        return "Please enter your number of sisters";
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),

          /// Sign Up button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                currentWizardIndex != 0
                    ? SizedBox(
                        width: MediaQuery.of(context).size.width / 3,
                        child: DefaultButton(
                          // child: Text(_i18n.translate("CREATE_ACCOUNT"),
                          child:
                              Text('Previous', style: TextStyle(fontSize: 18)),
                          onPressed: () {
                            setState(() {
                              currentWizardIndex -= 1;
                            });
                          },
                        ),
                      )
                    : SizedBox(),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: DefaultButton(
                    // child: Text(_i18n.translate("CREATE_ACCOUNT"),
                    child: Text('Next', style: TextStyle(fontSize: 18)),
                    onPressed: () {
                      setState(() {
                        // currentWizardIndex += 1;
                        if (_familyFormKey.currentState!.validate()) {
                          _familyFormKey.currentState!.save();
                          _createAccount();
                        } else {
                          showScaffoldMessage(
                              context: context,
                              message: 'Please fill all the mandatory fields');
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget UserDataSection() {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: <Widget>[
              // Text(_i18n.translate("create_account"),
              //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              // SizedBox(height: 20),
              //
              // /// Profile photo
              // GestureDetector(
              //   child: Center(
              //       child: _imageFile == null
              //           ? CircleAvatar(
              //               radius: 60,
              //               backgroundColor: Theme.of(context).primaryColor,
              //               child: SvgIcon("assets/icons/camera_icon.svg",
              //                   width: 40, height: 40, color: Colors.white),
              //             )
              //           : CircleAvatar(
              //               radius: 60,
              //               backgroundImage: FileImage(_imageFile!),
              //             )),
              //   onTap: () {
              //     /// Get profile image
              //     _getImage(context);
              //   },
              // ),
              // SizedBox(height: 10),
              // Text(_i18n.translate("profile_photo"), textAlign: TextAlign.center),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    width: MediaQuery.of(context).size.width / 2,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey[500]!,
                              offset: const Offset(4, 4),
                              blurRadius: 15,
                              spreadRadius: 1),
                          BoxShadow(
                              color: Colors.white,
                              offset: const Offset(-4, -4),
                              blurRadius: 15,
                              spreadRadius: 1)
                        ]),
                    height: MediaQuery.of(context).size.height / 4,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: SvgPicture.asset('assets/icons/basic_info.svg'),
                    )),
              ),

              SizedBox(height: 22),

              /// Form
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    /// FullName field
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey[500]!,
                                offset: const Offset(4, 4),
                                blurRadius: 15,
                                spreadRadius: 1),
                            BoxShadow(
                                color: Colors.white,
                                offset: const Offset(-4, -4),
                                blurRadius: 15,
                                spreadRadius: 1)
                          ]),
                      child: TextFormField(
                        style: TextStyle(color: Color(0xffff9c9c)),
                        controller: _nameController,
                        decoration: InputDecoration(
                            // labelText: _i18n.translate("fullname"),
                            hintText: _i18n.translate("enter_your_fullname"),
                            labelStyle: TextStyle(color: Color(0xffff9c9c)),
                            hintStyle: TextStyle(color: Color(0xffff9c9c)),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide.none,
                                borderRadius: BorderRadius.circular(28)),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: SvgIcon(
                                "assets/icons/user_icon.svg",
                                color: Color(0xffff9c9c),
                              ),
                            )),
                        validator: (name) {
                          // Basic validation
                          if (name?.isEmpty ?? false) {
                            return _i18n
                                .translate("please_enter_your_fullname");
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 20),

                    /// User gender
                    // Container(
                    //   decoration: BoxDecoration(
                    //       color: Colors.white,
                    //       borderRadius: BorderRadius.circular(28),
                    //       boxShadow: [
                    //         BoxShadow(
                    //             color: Colors.grey[500]!,
                    //             offset: const Offset(4, 4),
                    //             blurRadius: 15,
                    //             spreadRadius: 1),
                    //         BoxShadow(
                    //             color: Colors.white,
                    //             offset: const Offset(-4, -4),
                    //             blurRadius: 15,
                    //             spreadRadius: 1)
                    //       ]),
                    //   child: DropdownButtonFormField<String>(
                    //     style: TextStyle(color: Color(0xffff9c9c)),
                    //     decoration: InputDecoration(
                    //       border: OutlineInputBorder(borderSide: BorderSide.none)
                    //     ),
                    //     items: _genders.map((gender) {
                    //       return new DropdownMenuItem(
                    //         value: gender,
                    //         child: _i18n.translate("lang") != 'en'
                    //             ? Text(
                    //                 '${gender.toString()} - ${_i18n.translate(gender.toString().toLowerCase())}')
                    //             : Text(gender.toString()),
                    //       );
                    //     }).toList(),
                    //     hint: Text(
                    //       _i18n.translate("select_gender"),
                    //       style: TextStyle(color: Color(0xffff9c9c)),
                    //     ),
                    //     onChanged: (gender) {
                    //       setState(() {
                    //         _selectedGender = gender;
                    //       });
                    //     },
                    //     validator: (String? value) {
                    //       if (value == null) {
                    //         return _i18n.translate("please_select_your_gender");
                    //       }
                    //       return null;
                    //     },
                    //   ),
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: (){
                            setState(() {
                              isMaleSelected = true;
                              isFemaleSelected = false;
                              _selectedGender = "Male";
                            });
                          },
                          child: Container(
                            height: 150,
                            width: MediaQuery.of(context).size.width/2.3,
                            decoration: BoxDecoration(color: isMaleSelected! ? Color(0xff010b29) : Colors.white,borderRadius: BorderRadius.circular(20),boxShadow: [
                              BoxShadow(
                                  color: Colors.grey[500]!,
                                  offset: const Offset(4, 4),
                                  blurRadius: 15,
                                  spreadRadius: 1),
                              BoxShadow(
                                  color: Colors.white,
                                  offset: const Offset(-4, -4),
                                  blurRadius: 15,
                                  spreadRadius: 1)
                            ]),
                            child: Padding(
                              padding: const EdgeInsets.all(28.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset('assets/icons/male_symbol.png',height: 60,width: 60,),
                                  SizedBox(height: 10,),
                                  Text('MALE',style: TextStyle(color: Color(0xffff9c9c),),)
                                ],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: (){
                            setState(() {
                              isFemaleSelected = true;
                              isMaleSelected = false;
                              _selectedGender = "Female";
                            });
                          },
                          child: Container(
                            height: 150,
                            width: MediaQuery.of(context).size.width/2.3,
                            decoration: BoxDecoration(color: isFemaleSelected! ? Color(0xff010b29) : Colors.white,borderRadius: BorderRadius.circular(20),boxShadow: [
                            BoxShadow(
                            color: Colors.grey[500]!,
                                offset: const Offset(4, 4),
                                blurRadius: 15,
                                spreadRadius: 1),
                              BoxShadow(
                                  color: Colors.white,
                                  offset: const Offset(-4, -4),
                                  blurRadius: 15,
                                  spreadRadius: 1)
                              ]),
                            child: Padding(
                              padding: const EdgeInsets.all(28.0),
                              child: Column(
                                children: [
                                  Image.asset('assets/icons/female_symbol.png',height: 60,width: 60,),
                                  SizedBox(height: 10,),
                                  Text('FEMALE',style: TextStyle(color: Color(0xffff9c9c),),)
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    /// Birthday card
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey[500]!,
                                offset: const Offset(4, 4),
                                blurRadius: 15,
                                spreadRadius: 1),
                            BoxShadow(
                                color: Colors.white,
                                offset: const Offset(-4, -4),
                                blurRadius: 15,
                                spreadRadius: 1)
                          ]),
                      child: ListTile(
                        leading: SvgIcon("assets/icons/calendar_icon.svg", color: Color(0xffff9c9c),),
                        title: Text(_birthday ?? "Please select your birthday",
                            style: TextStyle(color: Color(0xffff9c9c))),
                        trailing: Icon(Icons.arrow_drop_down),
                        onTap: () {
                          /// Select birthday
                          _showDatePicker();
                        },
                      ),
                    ),
                    SizedBox(height: 25),

                    /// School field
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey[500]!,
                                offset: const Offset(4, 4),
                                blurRadius: 15,
                                spreadRadius: 1),
                            BoxShadow(
                                color: Colors.white,
                                offset: const Offset(-4, -4),
                                blurRadius: 15,
                                spreadRadius: 1)
                          ]),
                      child: TextFormField(
                        style: TextStyle(color: Color(0xffff9c9c)),
                        controller: _schoolController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                            hintText: _i18n.translate("enter_your_school_name"),
                            hintStyle: TextStyle(color: Color(0xffff9c9c)),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: SvgIcon("assets/icons/university_icon.svg",color: Color(0xffff9c9c),),
                            )),
                      ),
                    ),
                    SizedBox(height: 20),

                    /// Job title field
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey[500]!,
                                offset: const Offset(4, 4),
                                blurRadius: 15,
                                spreadRadius: 1),
                            BoxShadow(
                                color: Colors.white,
                                offset: const Offset(-4, -4),
                                blurRadius: 15,
                                spreadRadius: 1)
                          ]),
                      child: TextFormField(
                        style: TextStyle(color: Color(0xffff9c9c)),
                        controller: _jobController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderSide: BorderSide.none),
                            hintText: _i18n.translate("enter_your_job_title"),
                            hintStyle: TextStyle(color: Color(0xffff9c9c)),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: SvgIcon("assets/icons/job_bag_icon.svg",color: Color(0xffff9c9c),),
                            )),
                      ),
                    ),
                    SizedBox(height: 20),

                    /// Bio field
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey[500]!,
                                offset: const Offset(4, 4),
                                blurRadius: 15,
                                spreadRadius: 1),
                            BoxShadow(
                                color: Colors.white,
                                offset: const Offset(-4, -4),
                                blurRadius: 15,
                                spreadRadius: 1)
                          ]),
                      child: TextFormField(
                        style: TextStyle(color: Color(0xffff9c9c)),
                        controller: _bioController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none
                          ),
                          hintText: _i18n.translate("please_write_your_bio"),
                          hintStyle: TextStyle(color: Color(0xffff9c9c)),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SvgIcon("assets/icons/info_icon.svg", color: Color(0xffff9c9c),),
                          ),
                        ),
                        validator: (bio) {
                          if (bio?.isEmpty ?? false) {
                            return _i18n.translate("please_write_your_bio");
                          }
                          return null;
                        },
                      ),
                    ),

                    /// Agree terms
                    SizedBox(height: 5),
                    _agreePrivacy(),
                    SizedBox(height: 20),

                    /// Sign Up button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        currentWizardIndex != 0
                            ? SizedBox(
                                width: MediaQuery.of(context).size.width / 3,
                                child: DefaultButton(
                                  // child: Text(_i18n.translate("CREATE_ACCOUNT"),
                                  child: Text('Previous',
                                      style: TextStyle(fontSize: 18)),
                                  onPressed: () {
                                    setState(() {
                                      currentWizardIndex -= 1;
                                    });
                                  },
                                ),
                              )
                            : SizedBox(),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 3,
                          child: DefaultButton(
                            // child: Text(_i18n.translate("CREATE_ACCOUNT"),
                            child: Text('Next', style: TextStyle(fontSize: 18)),
                            onPressed: () {
                              setState(() {
                                /// check image file
                                // if (_imageFile == null) {
                                //   // Show error message
                                //   showScaffoldMessage(
                                //       context: context,
                                //       message: _i18n.translate(
                                //           "please_select_your_profile_photo"),
                                //       bgcolor: Colors.red);
                                //   // validate terms
                                // } else
                                if (!_agreeTerms) {
                                  // Show error message
                                  showScaffoldMessage(
                                      context: context,
                                      message: _i18n.translate(
                                          "you_must_agree_to_our_privacy_policy"),
                                      bgcolor: Colors.red);

                                  /// Validate form
                                } else if (UserModel()
                                        .calculateUserAge(_initialDateTime) <
                                    18) {
                                  // Show error message
                                  showScaffoldMessage(
                                      context: context,
                                      duration: Duration(seconds: 7),
                                      message: _i18n.translate(
                                          "only_18_years_old_and_above_are_allowed_to_create_an_account"),
                                      bgcolor: Colors.red);
                                } else if (!_formKey.currentState!.validate()) {

                                } else if(_selectedGender == null) {
                                  showScaffoldMessage(
                                      context: context,
                                      duration: Duration(seconds: 7),
                                      message: "Please select your gender",
                                      bgcolor: Colors.red);
                                } else {
                                  /// Call all input onSaved method
                                  _formKey.currentState!.save();

                                  _createAccount();
                                }

                                // /// Sign up
                                // if (currentWizardIndex == 4) {
                                //   _createAccount();
                                // }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle Create account
  void _createAccount() async {
    /// Call sign up method
    UserModel().signUp(
      userPhotoFile: _imageFile,
      userFullName: _nameController.text.trim(),
      userGender: _selectedGender!,
      userBirthDay: _userBirthDay,
      userBirthMonth: _userBirthMonth,
      userBirthYear: _userBirthYear,
      userSchool: _schoolController.text.trim(),
      userJobTitle: _jobController.text.trim(),
      userBio: _bioController.text.trim(),
      onSuccess: () async {
        // Show success message
        successDialog(context,
            message:
                _i18n.translate("your_account_has_been_created_successfully"),
            positiveAction: () {
          // Execute action
          _goToProfilePictureUpdateScreen();
        });
      },
      onFail: (error) {
        // Debug error
        debugPrint(error);
        // Show error message
        errorDialog(context,
            message: _i18n
                .translate("an_error_occurred_while_creating_your_account"));
      },
      numberOfSisters: noOfSisters.toString(),
      numberOfBrothers: noOfBrothers.toString(),
      ancestralVillage: selectedVillage.toString(),
      ancestralState: selectedState.toString(),
      gothra: _gothraController.text.trim(),
      subCaste: selectedSubCaste.toString(),
      caste: selectedCaste.toString(),
      userReligion: selectedReligion.toString(),
      mothersName: _motherNameController.text.trim(),
      fathersName: _fatherNameController.text.trim(),
    );
  }

  /// Handle Agree privacy policy
  Widget _agreePrivacy() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Checkbox(
            side: BorderSide(color: Color(0xffff9c9c)),
              activeColor: Color(0xffff9c9c),
              value: _agreeTerms,
              onChanged: (value) {
                _setAgreeTerms(value!);
              }),
          Row(
            children: <Widget>[
              GestureDetector(
                  onTap: () => _setAgreeTerms(!_agreeTerms),
                  child: Text(_i18n.translate("i_agree_with"),
                      style: TextStyle(fontSize: MediaQuery.of(context).size.width/30,color: Color(0xffff9c9c)))),
              // Terms of Service and Privacy Policy
              TermsOfServiceRow(color: Color(0xffff9c9c)),
            ],
          ),
        ],
      ),
    );
  }

  void _goToProfilePictureUpdateScreen() {
    /// Go to home screen
    Future(() {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => ProfilePictureUpdateScreen()),
          (route) => false);
    });
  }
}
