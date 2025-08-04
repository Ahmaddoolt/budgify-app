import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/utils/url_luncher_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTopButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset >= 300) {
        if (!_showScrollToTopButton) {
          setState(() {
            _showScrollToTopButton = true;
          });
        }
      } else {
        if (_showScrollToTopButton) {
          setState(() {
            _showScrollToTopButton = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // --- Text Styles (Defined once for consistency) ---
    final titleStyle = TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: colorScheme.primary,
    );
    final heading1Style = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
    );
    final heading2Style = TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: colorScheme.secondary,
    );
    final bodyStyle = TextStyle(
      // ignore: deprecated_member_use
      fontSize: 15,
      height: 1.5,
      color: colorScheme.onSurface.withOpacity(0.85),
    );
    final shortSummaryStyle = TextStyle(
      // ignore: deprecated_member_use
      fontSize: 15,
      height: 1.5,
      fontStyle: FontStyle.italic,
      color: colorScheme.onSurface.withOpacity(0.7),
    );

    // IMPORTANT: Replace placeholders in Lang.dart as well!
    const String yourCompanyName = "[Budgify]"; // Or load from config
    const String yourContactEmail =
        "[clovertec.co@gmail.com]"; // Or load from config
    const String yourLastUpdatedDate = "[2025/5/12]"; // Or load dynamically
    // const String yourStreetAddress = "[Your Street Address]"; // REMOVED
    // const String yourCityStateZip = "[Your City, State, Zip Code]"; // REMOVED
    // const String yourCountry = "[Your Country]"; // REMOVED

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 120.0,
            backgroundColor: colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Privacy Policy'.tr,
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                  // UrlLauncherButton(
                  //   url:
                  //       'https://doc-hosting.flycricket.io/budgify-privacy-policy/2f72fcc0-a478-479a-8519-09a0e0d7ce34/privacy',
                  //   label: 'Open Privacy Policy',
                  // ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    // ignore: deprecated_member_use
                    colors: [
                      colorScheme.primary,
                      // ignore: deprecated_member_use
                      colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
            ),
            iconTheme: IconThemeData(color: AppColors.accentColor),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionTitle(
                  'PRIVACY POLICY'.tr,
                  titleStyle,
                ), 
                _buildBodyText(
                  'Last updated: %s'.trArgs([yourLastUpdatedDate]),
                  bodyStyle.copyWith(fontStyle: FontStyle.italic),
                ), 
                const SizedBox(height: 16),
                _buildBodyText(
                  'Privacy Notice Intro'.trArgs([yourCompanyName]),
                  bodyStyle,
                ),
                const SizedBox(height: 8),
                _buildListItem(
                  'Privacy Notice App Usage'.tr,
                  bodyStyle,
                ), 
                _buildListItem(
                  'Privacy Notice Engagement'.tr,
                  bodyStyle,
                ), 
                const SizedBox(height: 16),
                _buildBodyText(
                  'Privacy Notice Questions'.trArgs([yourContactEmail]),
                  bodyStyle,
                ), 
                const SizedBox(height: 24),
                _buildDivider(),

                _buildSectionTitle(
                  'SUMMARY OF KEY POINTS'.tr,
                  heading1Style,
                ), 
                const SizedBox(height: 8),
                _buildBodyText(
                  'Summary Intro'.tr,
                  shortSummaryStyle,
                ), 
                const SizedBox(height: 16),
                _buildSummaryPoint(
                  'Summary What Process'.tr, 
                  'Summary What Process Desc'.tr, 
                  heading2Style,
                  bodyStyle,
                ),
                _buildSummaryPoint(
                  'Summary Sensitive Process'.tr, 
                  'Summary Sensitive Process Desc'
                      .tr, 
                  heading2Style,
                  bodyStyle,
                ),
                _buildSummaryPoint(
                  'Summary Third Party'.tr, 
                  'Summary Third Party Desc'
                      .tr, 
                  heading2Style,
                  bodyStyle,
                ),
                _buildSummaryPoint(
                  'Summary How Process'.tr, 
                  'Summary How Process Desc'.tr,
                  heading2Style,
                  bodyStyle,
                ),
                _buildSummaryPoint(
                  'Summary Share Situations'.tr, 
                  'Summary Share Situations Desc'.tr, 
                  heading2Style,
                  bodyStyle,
                ),
                _buildSummaryPoint(
                  'Summary Your Rights'.tr, 
                  'Summary Your Rights Desc'.tr, 
                  heading2Style,
                  bodyStyle,
                ),
                _buildSummaryPoint(
                  'Summary Exercise Rights'.tr, 
                  'Summary Exercise Rights Desc'.trArgs([
                    yourContactEmail,
                  ]), 
                  heading2Style,
                  bodyStyle,
                ),
                const SizedBox(height: 24),
                _buildDivider(),

                _buildSectionTitle(
                  'TABLE OF CONTENTS'.tr,
                  heading1Style,
                ), 
                const SizedBox(height: 8),
                _buildTocItem('TOC 1'.tr, bodyStyle), 
                _buildTocItem('TOC 2'.tr, bodyStyle),
                _buildTocItem('TOC 3'.tr, bodyStyle), // Key exists
                _buildTocItem('TOC 4'.tr, bodyStyle), // Key exists
                _buildTocItem('TOC 5'.tr, bodyStyle), // Key exists
                _buildTocItem('TOC 6'.tr, bodyStyle), // Key exists
                _buildTocItem('TOC 7'.tr, bodyStyle), // Key exists
                _buildTocItem('TOC 8'.tr, bodyStyle), // Key exists
                _buildTocItem('TOC 9'.tr, bodyStyle), // Key exists
                _buildTocItem('TOC 10'.tr, bodyStyle), // Key exists
                _buildTocItem('TOC 11'.tr, bodyStyle), // Key exists
                _buildTocItem('TOC 12'.tr, bodyStyle), // Key exists
                const SizedBox(height: 24),
                _buildDivider(),

                // --- Section 1: WHAT INFORMATION DO WE COLLECT? ---
                _buildSectionTitle(
                  'Section 1 Title'.tr,
                  heading1Style,
                ), // Key exists
                const SizedBox(height: 8),
                _buildHeading2(
                  'Section 1 Disclose Heading'.tr,
                  heading2Style,
                ), // Key exists
                _buildBodyText(
                  'Section 1 Disclose Short'.tr,
                  shortSummaryStyle,
                ), // Key exists
                const SizedBox(height: 8),
                _buildBodyText(
                  'Section 1 Disclose Body'.tr,
                  bodyStyle,
                ), // Key exists (Adjust content in Lang.dart for actions)
                const SizedBox(height: 8),
                _buildHeading2(
                  'Section 1 Provided Heading'.tr,
                  heading2Style,
                ), // Key exists
                _buildBodyText(
                  'Section 1 Provided Body'.tr,
                  bodyStyle,
                ), // Key exists
                const SizedBox(height: 4),
                // !! REPLACE THESE WITH YOUR ACTUAL DATA POINTS IN Lang.dart !!
                _buildListItem(
                  'Section 1 Provided Item Names'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 1 Provided Item Email'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 1 Provided Item Usernames'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 1 Provided Item Passwords'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 1 Provided Item Contact Prefs'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 1 Provided Item Financial'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 1 Provided Item Other'.tr,
                  bodyStyle,
                ), // Key exists (Adjust content in Lang.dart)
                const SizedBox(height: 16),
                _buildHeading2(
                  'Section 1 Sensitive Heading'.tr,
                  heading2Style,
                ), // Key exists
                _buildBodyText(
                  'Section 1 Sensitive Body'.tr,
                  bodyStyle,
                ), // Key exists (Adjust content in Lang.dart)
                const SizedBox(height: 16),
                _buildHeading2(
                  'Section 1 App Data Heading'.tr,
                  heading2Style,
                ), // Key exists
                _buildBodyText(
                  'Section 1 App Data Body'.tr,
                  bodyStyle,
                ), // Key exists
                const SizedBox(height: 4),
                _buildListItem(
                  'Section 1 App Data Item Push'.tr,
                  bodyStyle,
                ), // Key exists (Adjust content in Lang.dart for purpose)
                // !! ONLY INCLUDE THE FOLLOWING IF APPLICABLE & ADJUST CONTENT IN Lang.dart !!
                _buildListItem(
                  'Section 1 App Data Item Device Access'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 1 App Data Item Device Data'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 1 App Data Item Geolocation'.tr,
                  bodyStyle,
                ), // Key exists
                const SizedBox(height: 8),
                _buildBodyText(
                  'Section 1 App Data Purpose'.tr,
                  bodyStyle,
                ), // Key exists (Adjust content in Lang.dart)
                const SizedBox(height: 8),
                _buildBodyText(
                  'Section 1 App Data Accuracy'.tr,
                  bodyStyle,
                ), // Key exists
                const SizedBox(height: 16),
                // --- Optional: Information automatically collected ---
                _buildHeading2(
                  'Section 1 Auto Heading'.tr,
                  heading2Style,
                ), // Key exists
                _buildBodyText(
                  'Section 1 Auto Short'.tr,
                  shortSummaryStyle,
                ), // Key exists
                const SizedBox(height: 8),
                _buildBodyText(
                  'Section 1 Auto Body'.tr,
                  bodyStyle,
                ), // Key exists
                const SizedBox(height: 8),
                _buildBodyText(
                  'Section 1 Auto Cookies'.tr,
                  bodyStyle,
                ), // Key exists (Adjust content in Lang.dart)
                const SizedBox(height: 8),
                _buildBodyText(
                  'Section 1 Auto Includes'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 1 Auto Item Log'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 1 Auto Item Device'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 1 Auto Item Location'.tr,
                  bodyStyle,
                ), // Key exists (Adjust content in Lang.dart)
                const SizedBox(height: 24),
                _buildDivider(),

                // --- Section 2: HOW DO WE PROCESS YOUR INFORMATION? ---
                _buildSectionTitle(
                  'Section 2 Title'.tr,
                  heading1Style,
                ), // Key exists
                const SizedBox(height: 8),
                _buildBodyText(
                  'Section 2 Short'.tr,
                  shortSummaryStyle,
                ), // Key exists
                const SizedBox(height: 8),
                _buildBodyText('Section 2 Body'.tr, bodyStyle), // Key exists
                const SizedBox(height: 4),
                // !! ADJUST LIST BASED ON BUDGIFY FEATURES in Lang.dart !!
                _buildListItem(
                  'Section 2 Item Account'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 2 Item Deliver'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 2 Item Support'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 2 Item Admin'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 2 Item Feedback'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 2 Item Marketing'.tr,
                  bodyStyle,
                ), // Key exists (Adjust content in Lang.dart)
                _buildListItem(
                  'Section 2 Item Protect'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 2 Item Trends'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 2 Item Campaign'.tr,
                  bodyStyle,
                ), // Key exists (Adjust content in Lang.dart)
                _buildListItem(
                  'Section 2 Item Vital'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 2 Item Other'.tr,
                  bodyStyle,
                ), // Key exists (Adjust content in Lang.dart)
                const SizedBox(height: 24),
                _buildDivider(),

                // --- Section 3: WHAT LEGAL BASES DO WE RELY ON? ---
                _buildSectionTitle(
                  'Section 3 Title'.tr,
                  heading1Style,
                ), // Key exists
                const SizedBox(height: 8),
                _buildBodyText(
                  'Section 3 Short'.tr,
                  shortSummaryStyle,
                ), // Key exists
                const SizedBox(height: 8),
                // --- GDPR / UK Section ---
                _buildHeading2(
                  'Section 3 EU UK Heading'.tr,
                  heading2Style,
                ), // Key exists
                _buildBodyText(
                  'Section 3 EU UK Body'.tr,
                  bodyStyle,
                ), // Key exists
                const SizedBox(height: 4),
                _buildListItem(
                  'Section 3 Basis Consent'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 3 Basis Contract'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 3 Basis Legal'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 3 Basis Legitimate'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 3 Basis Vital'.tr,
                  bodyStyle,
                ), // Key exists
                const SizedBox(height: 16),
                // --- Canada Section ---
                _buildHeading2(
                  'Section 3 Canada Heading'.tr,
                  heading2Style,
                ), // Key exists
                _buildBodyText(
                  'Section 3 Canada Body'.tr,
                  bodyStyle,
                ), // Key exists
                const SizedBox(height: 24),
                _buildDivider(),

                // --- Section 4: WHEN AND WITH WHOM DO WE SHARE? ---
                _buildSectionTitle(
                  'Section 4 Title'.tr,
                  heading1Style,
                ), // Key exists
                const SizedBox(height: 8),
                _buildBodyText(
                  'Section 4 Short'.tr,
                  shortSummaryStyle,
                ), // Key exists
                const SizedBox(height: 8),
                _buildBodyText('Section 4 Body'.tr, bodyStyle), // Key exists
                const SizedBox(height: 4),
                _buildListItem(
                  'Section 4 Item Transfer'.tr,
                  bodyStyle,
                ), // Key exists
                // !! CRITICAL: CUSTOMIZE THIS LIST in Lang.dart !!
                _buildListItem(
                  'Section 4 Item Vendors'.tr,
                  bodyStyle,
                ), // Key exists
                // Add specific examples IF DESIRED in Lang.dart
                _buildListItem(
                  'Section 4 Item Affiliates'.tr,
                  bodyStyle,
                ), // Key exists (Adjust content in Lang.dart)
                _buildListItem(
                  'Section 4 Item Partners'.tr,
                  bodyStyle,
                ), // Key exists (Adjust content in Lang.dart)
                _buildListItem(
                  'Section 4 Item Consent'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 4 Item Legal'.tr,
                  bodyStyle,
                ), // Key exists
                const SizedBox(height: 24),
                _buildDivider(),

                // --- Section 5: HOW LONG DO WE KEEP YOUR INFORMATION? ---
                _buildSectionTitle(
                  'Section 5 Title'.tr,
                  heading1Style,
                ), // Key exists
                const SizedBox(height: 8),
                _buildBodyText(
                  'Section 5 Short'.tr,
                  shortSummaryStyle,
                ), // Key exists
                const SizedBox(height: 8),
                // !! BE MORE SPECIFIC IF POSSIBLE in Lang.dart !!
                _buildBodyText(
                  'Section 5 Body 1'.tr,
                  bodyStyle,
                ), // Key exists (Adjust content in Lang.dart for example)
                const SizedBox(height: 8),
                _buildBodyText('Section 5 Body 2'.tr, bodyStyle), // Key exists
                const SizedBox(height: 24),
                _buildDivider(),

                // --- Section 6: DO WE COLLECT INFORMATION FROM MINORS? ---
                _buildSectionTitle(
                  'Section 6 Title'.tr,
                  heading1Style,
                ), // Key exists
                const SizedBox(height: 8),
                _buildBodyText(
                  'Section 6 Short'.tr,
                  shortSummaryStyle,
                ), // Key exists
                const SizedBox(height: 8),
                // !! VERIFY AGE (18 is default) in Lang.dart !!
                _buildBodyText(
                  'Section 6 Body'.trArgs([yourContactEmail]),
                  bodyStyle,
                ), // Use dedicated key + interpolation
                const SizedBox(height: 24),
                _buildDivider(),

                // --- Section 7: WHAT ARE YOUR PRIVACY RIGHTS? ---
                _buildSectionTitle(
                  'Section 7 Title'.tr,
                  heading1Style,
                ), // Key exists
                const SizedBox(height: 8),
                _buildBodyText(
                  'Section 7 Short'.tr,
                  shortSummaryStyle,
                ), // Key exists
                const SizedBox(height: 8),
                _buildBodyText('Section 7 Body 1'.tr, bodyStyle), // Key exists
                const SizedBox(height: 8),
                _buildBodyText('Section 7 Body 2'.tr, bodyStyle), // Key exists
                const SizedBox(height: 8),
                _buildBodyText(
                  'Section 7 Body 3 EU UK'.tr,
                  bodyStyle,
                ), // Key exists
                _buildBodyText(
                  'Section 7 Body 4 Swiss'.tr,
                  bodyStyle,
                ), // Key exists
                const SizedBox(height: 16),
                _buildHeading2(
                  'Section 7 Withdraw Heading'.tr,
                  heading2Style,
                ), // Key exists
                _buildBodyText(
                  'Section 7 Withdraw Body'.tr,
                  bodyStyle,
                ), // Key exists
                const SizedBox(height: 16),
                // !! ADD IF BUDGIFY HAS ACCOUNTS & ADJUST METHOD IN Lang.dart !!
                _buildHeading2(
                  'Section 7 Account Heading'.tr,
                  heading2Style,
                ), // Key exists
                _buildBodyText(
                  'Section 7 Account Body'.tr,
                  bodyStyle,
                ), // Key exists
                const SizedBox(height: 24),
                _buildDivider(),

                // --- Section 8: CONTROLS FOR DO-NOT-TRACK FEATURES ---
                _buildSectionTitle(
                  'Section 8 Title'.tr,
                  heading1Style,
                ), // Key exists
                const SizedBox(height: 8),
                _buildBodyText('Section 8 Body'.tr, bodyStyle), // Key exists
                const SizedBox(height: 24),
                _buildDivider(),

                // --- Section 9: DO UNITED STATES RESIDENTS HAVE SPECIFIC PRIVACY RIGHTS? ---
                _buildSectionTitle(
                  'Section 9 Title'.tr,
                  heading1Style,
                ), // Key exists
                const SizedBox(height: 8),
                _buildBodyText(
                  'Section 9 Short'.tr,
                  shortSummaryStyle,
                ), // Key exists
                const SizedBox(height: 8),
                _buildBodyText(
                  'Section 9 Body 1'.tr,
                  bodyStyle,
                ), // Key exists (Adjust applicable states in Lang.dart)
                const SizedBox(height: 16),
                _buildHeading2(
                  'Section 9 Categories Heading'.tr,
                  heading2Style,
                ), // Key exists
                _buildBodyText(
                  'Section 9 Categories Body'.tr,
                  bodyStyle,
                ), // Key exists
                const SizedBox(height: 4),
                // !! CRITICAL: UPDATE YES/NO AND EXAMPLES FOR EACH CATEGORY IN Lang.dart !!
                _buildListItem(
                  'Section 9 Cat Item A'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 9 Cat Item B'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 9 Cat Item C'.tr,
                  bodyStyle,
                ), // Key exists - FIXED: Added .tr
                _buildListItem(
                  'Section 9 Cat Item D'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 9 Cat Item E'.tr,
                  bodyStyle,
                ), // Key exists - FIXED: Added .tr
                _buildListItem(
                  'Section 9 Cat Item F'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 9 Cat Item G'.tr,
                  bodyStyle,
                ), // Key exists - FIXED: Added .tr (Adjust YES/NO in Lang.dart)
                _buildListItem(
                  'Section 9 Cat Item H'.tr,
                  bodyStyle,
                ), // Key exists - FIXED: Added .tr
                _buildListItem(
                  'Section 9 Cat Item I'.tr,
                  bodyStyle,
                ), // Key exists - FIXED: Added .tr
                _buildListItem(
                  'Section 9 Cat Item J'.tr,
                  bodyStyle,
                ), // Key exists - FIXED: Added .tr
                _buildListItem(
                  'Section 9 Cat Item K'.tr,
                  bodyStyle,
                ), // Key exists (Adjust YES/NO in Lang.dart)
                _buildListItem(
                  'Section 9 Cat Item L'.tr,
                  bodyStyle,
                ), // Key exists (Adjust YES/NO in Lang.dart)
                const SizedBox(height: 8),
                _buildBodyText(
                  'Section 9 Categories Other'.tr,
                  bodyStyle,
                ), // Key exists
                const SizedBox(height: 16),
                _buildHeading2(
                  'Section 9 Sources Heading'.tr,
                  heading2Style,
                ), // Key exists
                _buildBodyText(
                  'Section 9 Sources Body'.tr,
                  bodyStyle,
                ), // Key exists
                const SizedBox(height: 16),
                _buildHeading2(
                  'Section 9 Use Share Heading'.tr,
                  heading2Style,
                ), // Key exists
                _buildBodyText(
                  'Section 9 Use Share Body'.tr,
                  bodyStyle,
                ), // Key exists
                const SizedBox(height: 16),
                _buildHeading2(
                  'Section 9 Shared Heading'.tr,
                  heading2Style,
                ), // Key exists
                _buildBodyText(
                  'Section 9 Shared Body 1'.tr,
                  bodyStyle,
                ), // Key exists
                const SizedBox(height: 8),
                _buildBodyText(
                  'Section 9 Shared Body 2'.tr,
                  bodyStyle,
                ), // Key exists
                const SizedBox(height: 8),
                // !! CRITICAL: REPLACE WITH YOUR ACTUAL STATEMENT ON SELLING/SHARING IN Lang.dart !!
                _buildBodyText(
                  'Section 9 Shared Body 3 Selling'.tr,
                  bodyStyle,
                ), // Key exists (Adjust content in Lang.dart)
                const SizedBox(height: 16),
                _buildHeading2(
                  'Section 9 Your Rights Heading'.tr,
                  heading2Style,
                ), // Key exists
                _buildBodyText(
                  'Section 9 Your Rights Body'.tr,
                  bodyStyle,
                ), // Key exists
                const SizedBox(height: 4),
                _buildListItem(
                  'Section 9 Right Know'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 9 Right Access'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 9 Right Correct'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 9 Right Delete'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 9 Right Copy'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 9 Right NonDiscrimination'.tr,
                  bodyStyle,
                ), // Key exists
                _buildListItem(
                  'Section 9 Right OptOut'.tr,
                  bodyStyle,
                ), // Key exists
                const SizedBox(height: 16),
                _buildHeading2(
                  'Section 9 Exercise Heading'.tr,
                  heading2Style,
                ), // Key exists
                _buildBodyText(
                  'Section 9 Exercise Body'.trArgs([yourContactEmail]),
                  bodyStyle,
                ), // Use dedicated key + interpolation (Adjust methods in Lang.dart)
                const SizedBox(height: 8),
                _buildBodyText(
                  'Section 9 Agent Body'.tr,
                  bodyStyle,
                ), // Key exists
                const SizedBox(height: 8),
                _buildHeading2(
                  'Section 9 Verification Heading'.tr,
                  heading2Style,
                ), // Key exists
                _buildBodyText(
                  'Section 9 Verification Body'.tr,
                  bodyStyle,
                ), // Key exists
                const SizedBox(height: 8),
                _buildHeading2(
                  'Section 9 Appeals Heading'.tr,
                  heading2Style,
                ), // Key exists
                _buildBodyText(
                  'Section 9 Appeals Body'.trArgs([yourContactEmail]),
                  bodyStyle,
                ), // Use dedicated key + interpolation
                const SizedBox(height: 16),
                _buildHeading2(
                  'Section 9 Shine Heading'.tr,
                  heading2Style,
                ), // Key exists
                _buildBodyText(
                  'Section 9 Shine Body'.tr,
                  bodyStyle,
                ), // Key exists
                const SizedBox(height: 24),
                _buildDivider(),

                // --- Section 10: DO WE MAKE UPDATES TO THIS NOTICE? ---
                _buildSectionTitle(
                  'Section 10 Title'.tr,
                  heading1Style,
                ), // Key exists
                const SizedBox(height: 8),
                _buildBodyText(
                  'Section 10 Short'.tr,
                  shortSummaryStyle,
                ), // Key exists
                const SizedBox(height: 8),
                _buildBodyText('Section 10 Body'.tr, bodyStyle), // Key exists
                const SizedBox(height: 24),
                _buildDivider(),

                // --- Section 11: HOW CAN YOU CONTACT US ABOUT THIS NOTICE? ---
                _buildSectionTitle(
                  'Section 11 Title'.tr,
                  heading1Style,
                ), // Key exists
                const SizedBox(height: 8),
                _buildBodyText(
                  'Section 11 Body 1'.trArgs([yourContactEmail]),
                  bodyStyle,
                ), // Use dedicated key + interpolation
                // const SizedBox(height: 8), // REMOVED or COMMENTED OUT
                // _buildBodyText('Section 11 Body 2 Address'.trArgs([yourCompanyName, yourStreetAddress, yourCityStateZip, yourCountry]), bodyStyle), // REMOVED or COMMENTED OUT as it uses deleted constants
                const SizedBox(height: 24),
                _buildDivider(),

                // --- Section 12: HOW CAN YOU REVIEW, UPDATE, OR DELETE THE DATA WE COLLECT FROM YOU? ---
                _buildSectionTitle(
                  'Section 12 Title'.tr,
                  heading1Style,
                ), // Key exists
                const SizedBox(height: 8),
                _buildBodyText('Section 12 Body 1'.tr, bodyStyle), // Key exists
                const SizedBox(height: 8),
                _buildBodyText(
                  'Section 12 Body 2 Method'.trArgs([yourContactEmail]),
                  bodyStyle,
                ), // Use dedicated key + interpolation (Adjust methods in Lang.dart)
                // --- End of Content ---
                const SizedBox(height: 40), // Extra space at the bottom
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton:
          _showScrollToTopButton
              ? FloatingActionButton(
                onPressed: _scrollToTop,
                tooltip: 'Scroll to top'.tr, // Key exists
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
                child: const Icon(Icons.arrow_upward),
              )
              : null,
    );
  }

  // --- Helper Widgets (Keep these as they are) ---

  Widget _buildSectionTitle(String text, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(text, style: style),
    );
  }

  Widget _buildHeading2(String text, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
      child: Text(text, style: style),
    );
  }

  Widget _buildBodyText(String text, TextStyle style) {
    // Use GetX's trArgs for interpolation if needed
    return Text(text, style: style);
  }

  Widget _buildListItem(String text, TextStyle itemStyle) {
    // Use GetX's trArgs for interpolation if needed within the text string
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: itemStyle.copyWith(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: itemStyle)),
        ],
      ),
    );
  }

  Widget _buildSummaryPoint(
    String title,
    String description,
    TextStyle titleStyle,
    TextStyle descriptionStyle,
  ) {
    // Use GetX's trArgs for interpolation if needed within title or description
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: titleStyle.copyWith(fontSize: 16, height: 1.4)),
          const SizedBox(height: 4),
          Text(description, style: descriptionStyle),
        ],
      ),
    );
  }

  Widget _buildTocItem(String text, TextStyle style) {
    // Use GetX's trArgs for interpolation if needed within the text string
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Text(text, style: style),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
    );
  }
}
