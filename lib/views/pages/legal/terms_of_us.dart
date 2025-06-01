import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/utils/url_luncher_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX

// --- Placeholder Data (Replace with your actual info!) ---
const String yourCompanyName = "Budgify";
const String yourCompanyEmail = "clovertec.co@gmail.com";
// const String yourCompanyAddress = "[Your Full Company Mailing Address Here]";
const String lastUpdatedDate = "May 12, 2025";
const String privacyPolicyUrl =
    "[Link to Your Privacy Policy]"; // e.g., 'https://yoursite.com/privacy'
// --- Removed unused privacyPolicyUrl, handle linking separately if needed ---
const String dataHostingLocation = "Lebanon";
const String governingLawJurisdiction = "Lebanon"; // As per image
const String arbitrationLocation =
    "Belgium, Brussels, Avenue Louise, 146"; // As per image
const String arbitrationRules = "European Arbitration Chamber"; // As per image
const int informalNegotiationDays = 30; // Example value, check your needs
const int numberOfArbitrators = 1; // Example value, check your needs
const String arbitrationLanguage = "English"; // Example value, check your needs
const String arbitrationSubstantiveLaw = "Lebanon"; // As per image
const String paymentCurrency = "USD"; // Example: Set your default currency

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  // Helper function for consistent section titles
  Widget _buildSectionTitle(BuildContext context, String titleKey) {
    // Changed to titleKey
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        titleKey.tr, // Use .tr
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.accentColor,
        ),
      ),
    );
  }

  // Helper function for sub-section titles (like 'Our intellectual property')
  Widget _buildSubSectionTitle(BuildContext context, String titleKey) {
    // Added helper
    return Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
        bottom: 8.0,
      ), // Adjusted padding
      child: Text(
        titleKey.tr, // Use .tr
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Helper function for paragraphs
  Widget _buildParagraph(String textKey, {Map<String, String>? params}) {
    // Changed to textKey, added optional params
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        params != null
            ? textKey.trParams(params)
            : textKey.tr, // Use .tr or .trParams
        style: const TextStyle(height: 1.5), // Improves readability
        textAlign: TextAlign.justify, // Justify text for a formal look
      ),
    );
  }

  // Helper function for bullet points
  Widget _buildListItem(String textKey, {Map<String, String>? params}) {
    // Changed to textKey, added optional params
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(height: 1.5)),
          Expanded(
            child: Text(
              params != null
                  ? textKey.trParams(params)
                  : textKey.tr, // Use .tr or .trParams
              style: const TextStyle(height: 1.5),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }

  // --- NOTE: You need to add ALL the keys used below (e.g., 'tou_title', 'tou_last_updated', 'tou_agreement_title', etc.)
  // --- to your Lang.dart file for English and all other supported languages.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('tou_appbar_title'.tr), // Key for AppBar title
        elevation: 1, // Subtle shadow
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'tou_title'.tr, // Key for main title
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                UrlLauncherButton(
                  url:
                      'https://doc-hosting.flycricket.io/budgify-terms-of-use/160dfe11-3038-4c3a-ba97-10ce73ae7963/terms',
                  label: 'Open Privacy Policy',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'tou_last_updated'.trParams({'date': lastUpdatedDate}),
            ), // Key with date param
            const SizedBox(height: 24),

            // --- AGREEMENT ---
            _buildSectionTitle(context, 'tou_agreement_title'),
            _buildParagraph(
              'tou_agreement_para1',
              params: {'companyName': yourCompanyName},
            ),
            _buildParagraph('tou_agreement_para2'),
            _buildParagraph('tou_agreement_para3'),
            _buildParagraph(
              'tou_agreement_para4',
              params: {'email': yourCompanyEmail, 'address': ""},
            ),
            _buildParagraph(
              'tou_agreement_para5',
              params: {'companyName': yourCompanyName},
            ),
            _buildParagraph('tou_agreement_para6'),
            _buildParagraph('tou_agreement_para7'),
            const SizedBox(height: 24),

            // --- TABLE OF CONTENTS ---
            _buildSectionTitle(context, 'tou_toc_title'),
            _buildParagraph('tou_toc_1'),
            _buildParagraph('tou_toc_2'),
            _buildParagraph('tou_toc_3'),
            _buildParagraph('tou_toc_4'),
            _buildParagraph('tou_toc_5'),
            _buildParagraph('tou_toc_6'),
            _buildParagraph('tou_toc_7'),
            _buildParagraph('tou_toc_8'),
            _buildParagraph('tou_toc_9'),
            _buildParagraph('tou_toc_10'),
            _buildParagraph('tou_toc_11'),
            _buildParagraph('tou_toc_12'),
            _buildParagraph('tou_toc_13'),
            _buildParagraph('tou_toc_14'),
            _buildParagraph('tou_toc_15'),
            _buildParagraph('tou_toc_16'),
            _buildParagraph('tou_toc_17'),
            _buildParagraph('tou_toc_18'),
            _buildParagraph('tou_toc_19'),
            _buildParagraph('tou_toc_20'),
            _buildParagraph('tou_toc_21'),
            _buildParagraph('tou_toc_22'),
            _buildParagraph('tou_toc_23'),
            _buildParagraph('tou_toc_24'),
            const SizedBox(height: 24),

            // --- 1. OUR SERVICES ---
            _buildSectionTitle(
              context,
              'tou_services_title',
            ), // Reusing toc_1 key is okay if text is identical
            _buildParagraph('tou_services_para1'),
            _buildParagraph('tou_services_para2'),

            // --- 2. INTELLECTUAL PROPERTY RIGHTS ---
            _buildSectionTitle(context, 'tou_ip_title'), // Reusing toc_2 key
            _buildSubSectionTitle(context, 'tou_ip_subheading_our'),
            _buildParagraph('tou_ip_para1'),
            _buildParagraph('tou_ip_para2'),
            _buildParagraph('tou_ip_para3'),

            _buildSubSectionTitle(context, 'tou_ip_subheading_your_use'),
            _buildParagraph('tou_ip_para4'),
            _buildListItem('tou_ip_item1'),
            _buildListItem('tou_ip_item2'),
            _buildParagraph('tou_ip_para5'),
            _buildParagraph('tou_ip_para6'),
            _buildParagraph(
              'tou_ip_para7',
              params: {'email': yourCompanyEmail},
            ),
            _buildParagraph('tou_ip_para8'),
            _buildParagraph('tou_ip_para9'),

            _buildSubSectionTitle(context, 'tou_ip_subheading_submissions'),
            _buildParagraph('tou_ip_para10'),
            _buildParagraph('tou_ip_para11'),
            _buildParagraph('tou_ip_para12'),
            _buildListItem('tou_ip_item3'),
            _buildListItem('tou_ip_item4'),
            _buildListItem('tou_ip_item5'),
            _buildListItem('tou_ip_item6'),
            _buildParagraph('tou_ip_para13'),

            // --- 3. USER REPRESENTATIONS ---
            _buildSectionTitle(context, 'tou_user_reps_title'), // Reusing toc_3
            _buildParagraph('tou_user_reps_para1'),
            _buildParagraph('tou_user_reps_para2'),

            // --- 4. PURCHASES AND PAYMENT ---
            _buildSectionTitle(context, 'tou_payment_title'), // Reusing toc_4
            _buildParagraph(
              'tou_payment_methods',
            ), // Key for the payment methods list
            _buildParagraph(
              'tou_payment_para1',
              params: {'currency': paymentCurrency},
            ),
            _buildParagraph('tou_payment_para2'),
            _buildParagraph('tou_payment_para3'),

            // --- 5. SOFTWARE ---
            _buildSectionTitle(context, 'tou_software_title'), // Reusing toc_5
            _buildParagraph('tou_software_para1'),

            // --- 6. PROHIBITED ACTIVITIES ---
            _buildSectionTitle(
              context,
              'tou_prohibited_title',
            ), // Reusing toc_6
            _buildParagraph('tou_prohibited_para1'),
            _buildParagraph('tou_prohibited_para2'),
            _buildListItem('tou_prohibited_item1'),
            _buildListItem('tou_prohibited_item2'),
            _buildListItem('tou_prohibited_item3'),
            _buildListItem('tou_prohibited_item4'),
            _buildListItem('tou_prohibited_item5'),
            _buildListItem('tou_prohibited_item6'),
            _buildListItem('tou_prohibited_item7'),
            _buildListItem('tou_prohibited_item8'),
            _buildListItem('tou_prohibited_item9'),
            _buildListItem('tou_prohibited_item10'),
            _buildListItem('tou_prohibited_item11'),
            _buildListItem('tou_prohibited_item12'),
            _buildListItem('tou_prohibited_item13'),
            _buildListItem('tou_prohibited_item14'),
            _buildListItem('tou_prohibited_item15'),
            _buildListItem('tou_prohibited_item16'),
            _buildListItem('tou_prohibited_item17'),
            _buildListItem('tou_prohibited_item18'),
            _buildListItem('tou_prohibited_item19'),
            _buildListItem('tou_prohibited_item20'),
            _buildListItem('tou_prohibited_item21'),
            _buildListItem('tou_prohibited_item22'), // Added missing item keys
            // --- 7. USER GENERATED CONTRIBUTIONS ---
            _buildSectionTitle(context, 'tou_ugc_title'), // Reusing toc_7
            _buildParagraph('tou_ugc_para1'),
            _buildListItem('tou_ugc_item1'),
            _buildListItem('tou_ugc_item2'),
            _buildListItem('tou_ugc_item3'),
            _buildListItem('tou_ugc_item4'),
            _buildListItem('tou_ugc_item5'),
            _buildListItem('tou_ugc_item6'),
            _buildListItem('tou_ugc_item7'),
            _buildListItem('tou_ugc_item8'),
            _buildListItem('tou_ugc_item9'),
            _buildListItem('tou_ugc_item10'),
            _buildListItem('tou_ugc_item11'),
            _buildListItem('tou_ugc_item12'),
            _buildListItem('tou_ugc_item13'),
            _buildParagraph('tou_ugc_para2'),

            // --- 8. CONTRIBUTION LICENSE ---
            _buildSectionTitle(
              context,
              'tou_contrib_license_title',
            ), // Reusing toc_8
            _buildParagraph('tou_contrib_license_para1'),
            _buildParagraph('tou_contrib_license_para2'),
            _buildParagraph('tou_contrib_license_para3'),

            // --- 9. MOBILE APPLICATION LICENSE ---
            _buildSectionTitle(
              context,
              'tou_mobile_license_title',
            ), // Reusing toc_9
            _buildSubSectionTitle(context, 'tou_mobile_license_subheading_use'),
            _buildParagraph('tou_mobile_license_para1'),
            _buildSubSectionTitle(
              context,
              'tou_mobile_license_subheading_devices',
            ),
            _buildParagraph('tou_mobile_license_para2'),

            // --- 10. SERVICES MANAGEMENT ---
            _buildSectionTitle(context, 'tou_mgmt_title'), // Reusing toc_10
            _buildParagraph('tou_mgmt_para1'),

            // --- 11. PRIVACY POLICY ---
            _buildSectionTitle(context, 'tou_privacy_title'), // Reusing toc_11
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: DefaultTextStyle.of(
                    context,
                  ).style.copyWith(height: 1.5),
                  children: <TextSpan>[
                    TextSpan(text: 'tou_privacy_para1_prefix'.tr),
                    // --- Placeholder for potential clickable link ---
                    // If you implement _buildLink or similar:
                    // WidgetSpan(child: _buildLink(context, 'Privacy Policy', privacyPolicyUrl)),
                    // If just text:
                    TextSpan(
                      text:
                          'tou_privacy_policy_link_text'
                              .tr, // Key for "Privacy Policy" text itself
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ), // Example styling
                      // Add recognizer here if making it clickable
                    ),
                    TextSpan(
                      text: 'tou_privacy_para1_suffix1'.trParams({
                        // Key for text after link, before location 1
                        'location': dataHostingLocation,
                      }),
                    ),
                    // TextSpan(
                    //   text: dataHostingLocation, // Variable inserted directly
                    //   style: const TextStyle(fontWeight: FontWeight.bold),
                    // ),
                    TextSpan(
                      text: 'tou_privacy_para1_suffix2'.trParams({
                        // Key for text between locations
                        'location': dataHostingLocation,
                      }),
                    ),
                    // TextSpan(
                    //   text: dataHostingLocation, // Variable inserted directly
                    //   style: const TextStyle(fontWeight: FontWeight.bold),
                    // ),
                    TextSpan(
                      text: 'tou_privacy_para1_suffix3'.trParams({
                        // Key for text after location 2
                        'location': dataHostingLocation,
                      }),
                    ),
                    // TextSpan(
                    //   text: dataHostingLocation, // Variable inserted directly
                    //   style: const TextStyle(fontWeight: FontWeight.bold),
                    // ),
                    TextSpan(
                      text: 'tou_privacy_para1_end'.tr,
                    ), // Key for the final period/sentence end
                  ],
                ),
              ),
            ),

            // --- 12. TERM AND TERMINATION ---
            _buildSectionTitle(context, 'tou_term_title'), // Reusing toc_12
            _buildParagraph('tou_term_para1'),
            _buildParagraph('tou_term_para2'),

            // --- 13. MODIFICATIONS AND INTERRUPTIONS ---
            _buildSectionTitle(
              context,
              'tou_modifications_title',
            ), // Reusing toc_13
            _buildParagraph('tou_modifications_para1'),
            _buildParagraph('tou_modifications_para2'),

            // --- 14. GOVERNING LAW ---
            _buildSectionTitle(context, 'tou_gov_law_title'), // Reusing toc_14
            _buildParagraph(
              'tou_gov_law_para1',
              params: {
                'jurisdiction': governingLawJurisdiction,
                'companyName': yourCompanyName,
              },
            ),

            // --- 15. DISPUTE RESOLUTION ---
            _buildSectionTitle(context, 'tou_dispute_title'), // Reusing toc_15
            _buildSubSectionTitle(context, 'tou_dispute_subheading_informal'),
            _buildParagraph(
              'tou_dispute_para1',
              params: {'days': informalNegotiationDays.toString()},
            ),

            _buildSubSectionTitle(context, 'tou_dispute_subheading_binding'),
            _buildParagraph(
              'tou_dispute_para2',
              params: {
                'rules': arbitrationRules,
                'location': arbitrationLocation,
                'numArbitrators': numberOfArbitrators.toString(),
                'language': arbitrationLanguage,
                'substantiveLaw': arbitrationSubstantiveLaw,
              },
            ),

            _buildSubSectionTitle(
              context,
              'tou_dispute_subheading_restrictions',
            ),
            _buildParagraph('tou_dispute_para3'),

            _buildSubSectionTitle(context, 'tou_dispute_subheading_exceptions'),
            _buildParagraph('tou_dispute_para4'),

            // --- 16. CORRECTIONS ---
            _buildSectionTitle(
              context,
              'tou_corrections_title',
            ), // Reusing toc_16
            _buildParagraph('tou_corrections_para1'),

            // --- 17. DISCLAIMER ---
            _buildSectionTitle(
              context,
              'tou_disclaimer_title',
            ), // Reusing toc_17
            _buildParagraph('tou_disclaimer_para1'),

            // --- 18. LIMITATIONS OF LIABILITY ---
            _buildSectionTitle(
              context,
              'tou_liability_title',
            ), // Reusing toc_18
            _buildParagraph('tou_liability_para1'),

            // --- 19. INDEMNIFICATION ---
            _buildSectionTitle(
              context,
              'tou_indemnification_title',
            ), // Reusing toc_19
            _buildParagraph('tou_indemnification_para1'),

            // --- 20. USER DATA ---
            _buildSectionTitle(context, 'tou_userdata_title'), // Reusing toc_20
            _buildParagraph('tou_userdata_para1'),

            // --- 21. ELECTRONIC COMMUNICATIONS ---
            _buildSectionTitle(context, 'tou_ecomms_title'), // Reusing toc_21
            _buildParagraph('tou_ecomms_para1'),

            // --- 22. CALIFORNIA USERS ---
            _buildSectionTitle(
              context,
              'tou_california_title',
            ), // Reusing toc_22
            _buildParagraph('tou_california_para1'),

            // --- 23. MISCELLANEOUS ---
            _buildSectionTitle(context, 'tou_misc_title'), // Reusing toc_23
            _buildParagraph('tou_misc_para1'),

            // --- 24. CONTACT US ---
            _buildSectionTitle(context, 'tou_contact_title'), // Reusing toc_24
            _buildParagraph('tou_contact_para1'),
            _buildParagraph(
              'tou_contact_para2',
              params: {'companyName': yourCompanyName},
            ),
            _buildParagraph('tou_contact_para3', params: {'address': ""}),
            _buildParagraph(
              'tou_contact_para4',
              params: {'email': yourCompanyEmail},
            ),

            const SizedBox(height: 30), // Extra space at the bottom
          ],
        ),
      ),
    );
  }
}
