import 'package:budgify/domain/models/onboarding_model.dart';
import 'app_constants.dart';

const onBoardingList = [
  OnBoardingModel(
    title: "Manage Finances",
    body: "Organize expenses by category \n and choose your language for a \n personalized experience.",
    image: AppConstants.onBoardingImageFour,
  ),
  OnBoardingModel(
    title: "Control Income Tracking",
    body: "Easily turn on or off income tracking \n based on your preferences. Stay focused \n on what matters to you.",
    image: AppConstants.onBoardingImageTwo,
  ),
  OnBoardingModel(
    title: "Track Your Expenses",
    body: "Easily monitor where your money goes \n Select your preferred currency to \n get started and stay in control.",
    image: AppConstants.onBoardingImageOne,
  ),
  OnBoardingModel(
    title: "Save Money Wisely",
    body: "Reach your financial goals faster. \n Let's get started!",
    image: AppConstants.onBoardingImageThree,
  ),
];