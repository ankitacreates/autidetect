import 'package:flutter/material.dart';
import 'package:autidetect/constants/colors.dart';
import 'package:autidetect/constants/strings.dart';
import 'package:autidetect/widgets/custom_card.dart';

class ResourcesScreen extends StatefulWidget {
  final int initialTabIndex;
  
  const ResourcesScreen({
    Key? key,
    this.initialTabIndex = 0,
  }) : super(key: key);

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4, 
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.resources),
        centerTitle: true,
        backgroundColor: AppColors.primaryDark,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent1,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: [
            Tab(text: AppStrings.educationalContent),
            Tab(text: AppStrings.developmentalMilestones),
            Tab(text: AppStrings.localServices),
            Tab(text: AppStrings.frequentlyAskedQuestions),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEducationalContent(),
          _buildDevelopmentalMilestones(),
          _buildLocalServices(),
          _buildFAQ(),
        ],
      ),
    );
  }

  Widget _buildEducationalContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Understanding Autism',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            title: 'What is Autism?',
            content: 'Autism, or autism spectrum disorder (ASD), refers to a broad range of conditions characterized by challenges with social skills, repetitive behaviors, speech, and nonverbal communication. There is not one autism but many subtypes, and each person with autism can have unique strengths and challenges.',
            icon: Icons.info_outline,
          ),
          _buildInfoCard(
            title: 'Signs and Symptoms',
            content: 'Early signs of autism may include limited eye contact, lack of response to their name, delayed language development, repetitive movements, and intense reactions to sensory experiences. Every child develops at their own pace, but being aware of these potential indicators can help with early identification.',
            icon: Icons.visibility,
          ),
          _buildInfoCard(
            title: 'Benefits of Early Detection',
            content: 'Research shows that early intervention can improve outcomes significantly. Children who receive appropriate therapies and support before age 3-5 often show better cognitive, social, and communication development over time.',
            icon: Icons.access_time,
          ),
          _buildInfoCard(
            title: 'Types of Interventions',
            content: 'There are many evidence-based interventions for autism, including Applied Behavior Analysis (ABA), speech therapy, occupational therapy, social skills training, and more. Each intervention should be tailored to the individual child\'s needs.',
            icon: Icons.healing,
          ),
          _buildInfoCard(
            title: 'Supporting Your Child',
            content: 'Creating a supportive environment involves understanding your child\'s sensory needs, establishing routines, using visual supports, celebrating their unique strengths, and advocating for appropriate accommodations in educational settings.',
            icon: Icons.favorite,
          ),
          _buildInfoCard(
            title: 'Autism and the Family',
            content: 'Having a child with autism affects the entire family. Siblings may need special attention and education about autism. Parents should remember to practice self-care and seek support groups or counseling if needed.',
            icon: Icons.family_restroom,
          ),
        ],
      ),
    );
  }

  Widget _buildDevelopmentalMilestones() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Developmental Milestones',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Understanding typical development can help identify potential concerns. These milestones represent average ages, but development varies among children.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildMilestoneCard(
            ageRange: '6 months',
            milestones: [
              'Responds to own name',
              'Recognizes familiar faces',
              'Begins to babble',
              'Shows interest in objects by reaching',
              'Brings objects to mouth',
              'Begins to sit without support',
            ],
          ),
          _buildMilestoneCard(
            ageRange: '12 months',
            milestones: [
              'Uses simple gestures like waving',
              'Says "mama" and "dada"',
              'Follows simple directions',
              'Plays simple games like peek-a-boo',
              'Pulls up to stand and walks while holding furniture',
              'Shows preferences for certain people and toys',
            ],
          ),
          _buildMilestoneCard(
            ageRange: '18 months',
            milestones: [
              'Points to show things to others',
              'Can say several single words',
              'Shows affection to familiar people',
              'Plays simple pretend games',
              'Walks alone',
              'Can follow 1-step verbal commands',
            ],
          ),
          _buildMilestoneCard(
            ageRange: '24 months',
            milestones: [
              'Uses 2-4 word phrases',
              'Follows 2-step instructions',
              'Shows increased interest in other children',
              'Points to named objects or pictures',
              'Begins to sort shapes and colors',
              'Plays make-believe with dolls, animals, and people',
            ],
          ),
          _buildMilestoneCard(
            ageRange: '36 months',
            milestones: [
              'Uses sentences with 3 or more words',
              'Engages in conversation',
              'Shows concern for a crying friend',
              'Takes turns in games',
              'Climbs well, runs easily, pedals a tricycle',
              'Shows affection for friends without prompting',
            ],
          ),
          _buildMilestoneCard(
            ageRange: '4-5 years',
            milestones: [
              'Tells stories and recalls parts of stories',
              'Plays cooperatively with other children',
              'Understands the concept of counting',
              'Speaks clearly in full sentences',
              'Shows independence in many activities',
              'Follows multi-step directions',
            ],
          ),
          const SizedBox(height: 16),
          _buildAutismRedFlagsCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard({
    required String ageRange,
    required List<String> milestones,
  }) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              ageRange,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...milestones.map((milestone) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        milestone,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildAutismRedFlagsCard() {
    return CustomCard(
      backgroundColor: AppColors.accent1.withOpacity(0.2),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Potential Signs of Autism',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          _buildRedFlagItem('Limited or no eye contact'),
          _buildRedFlagItem('Delayed language development'),
          _buildRedFlagItem('Difficulty with back-and-forth conversation'),
          _buildRedFlagItem('Repetitive movements or behaviors'),
          _buildRedFlagItem('Intense reactions to sensory experiences'),
          _buildRedFlagItem('Restricted interests or play patterns'),
          _buildRedFlagItem('Difficulty understanding social cues'),
          _buildRedFlagItem('Regression in previously acquired skills'),
          const SizedBox(height: 12),
          Text(
            'If you notice multiple signs, consider discussing them with a healthcare provider. Early evaluation is important.',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRedFlagItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.priority_high,
            color: AppColors.warning,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalServices() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Local Services & Support',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Finding local resources can make a significant difference in accessing timely support for your child.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildServiceCategory(
            title: 'Diagnostic Services',
            description: 'Centers that provide comprehensive autism evaluations',
            services: [
              ServiceInfo(
                name: 'Children\'s Developmental Center',
                description: 'Full multidisciplinary evaluations for children 0-8 years',
                contact: '(555) 123-4567',
                website: 'www.childrenscenter.org',
              ),
              ServiceInfo(
                name: 'University Autism Research Clinic',
                description: 'Research-based diagnostic services with sliding scale fees',
                contact: '(555) 987-6543',
                website: 'www.universityautism.edu',
              ),
              ServiceInfo(
                name: 'Pediatric Neurodevelopmental Associates',
                description: 'Neurological and developmental assessments for children of all ages',
                contact: '(555) 456-7890',
                website: 'www.pedneuro.org',
              ),
            ],
          ),
          _buildServiceCategory(
            title: 'Early Intervention Programs',
            description: 'Services for children under 3 years with developmental concerns',
            services: [
              ServiceInfo(
                name: 'Early Steps',
                description: 'State-funded early intervention for children 0-36 months',
                contact: '(555) 234-5678',
                website: 'www.earlysteps.org',
              ),
              ServiceInfo(
                name: 'First Words Project',
                description: 'Communication-focused interventions for toddlers',
                contact: '(555) 876-5432',
                website: 'www.firstwordsproject.org',
              ),
              ServiceInfo(
                name: 'Little Learners',
                description: 'Parent-child interactive therapy and play-based interventions',
                contact: '(555) 345-6789',
                website: 'www.littlelearners.org',
              ),
            ],
          ),
          _buildServiceCategory(
            title: 'Therapy Providers',
            description: 'Speech, occupational, and behavioral therapy services',
            services: [
              ServiceInfo(
                name: 'Comprehensive Therapy Center',
                description: 'Integrated therapy including ABA, speech, and occupational therapy',
                contact: '(555) 567-8901',
                website: 'www.comprehensivetherapy.org',
              ),
              ServiceInfo(
                name: 'Pediatric Therapy Solutions',
                description: 'Sensory integration, speech therapy, and feeding services',
                contact: '(555) 789-0123',
                website: 'www.pedtherapy.org',
              ),
              ServiceInfo(
                name: 'Behavioral Interventions Group',
                description: 'ABA therapy, social skills groups, and parent training',
                contact: '(555) 901-2345',
                website: 'www.behavioralinterventions.org',
              ),
            ],
          ),
          _buildServiceCategory(
            title: 'Support Groups',
            description: 'Connect with other families for support and resources',
            services: [
              ServiceInfo(
                name: 'Parent to Parent Network',
                description: 'Peer support from experienced parents of children with autism',
                contact: '(555) 432-1098',
                website: 'www.parenttoparent.org',
              ),
              ServiceInfo(
                name: 'Autism Family Alliance',
                description: 'Monthly meetings, respite care information, and family events',
                contact: '(555) 654-3210',
                website: 'www.autismfamily.org',
              ),
              ServiceInfo(
                name: 'Sibling Support Group',
                description: 'Support and activities for siblings of children with autism',
                contact: '(555) 876-5432',
                website: 'www.siblingsupport.org',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accent1.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent1.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Find Local Resources',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'The services listed are examples for demonstration purposes. For a personalized list of resources in your area, search for:',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildResourceBullet('State early intervention program'),
                _buildResourceBullet('Local autism support organizations'),
                _buildResourceBullet('School district special education department'),
                _buildResourceBullet('University-affiliated autism centers'),
                _buildResourceBullet('Health insurance network providers'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Autism Response Team: 1-888-AUTISM2',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.language,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'www.autismspeaks.org/resource-directory',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find answers to common questions about autism, evaluation, and intervention.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildFaqItem(
            question: 'What is the difference between autism screening and diagnosis?',
            answer: 'Screening is a brief check for warning signs of autism, like the assessment in this app. It helps identify children who might need further evaluation. Diagnosis is a comprehensive assessment done by healthcare professionals that can include interviews, observations, and standardized tests. Only qualified medical professionals can make an official autism diagnosis.',
          ),
          _buildFaqItem(
            question: 'At what age can autism be diagnosed?',
            answer: 'Autism can be reliably diagnosed by age 2, and sometimes earlier. Early signs may be noticed in the first year of life. Many children are not diagnosed until later in childhood, especially those with milder symptoms. Research shows that early diagnosis leads to better outcomes, as it allows for earlier intervention.',
          ),
          _buildFaqItem(
            question: 'What causes autism?',
            answer: 'There is no single known cause of autism. Research suggests a combination of genetic and environmental factors. Autism tends to run in families, suggesting a genetic component. Certain environmental influences during pregnancy and early development may also play a role. Importantly, vaccines do not cause autism - this has been extensively studied and disproven.',
          ),
          _buildFaqItem(
            question: 'What are the early signs of autism?',
            answer: 'Early signs may include limited eye contact, lack of response to name, delayed language or babbling, repetitive movements, not pointing at objects of interest, reduced social smiling, limited back-and-forth interaction, intense reactions to certain sensory experiences, and regression in previously acquired skills. Not all children will show all signs, and some signs overlap with other developmental conditions.',
          ),
          _buildFaqItem(
            question: 'What therapies are effective for autism?',
            answer: 'Evidence-based interventions include Applied Behavior Analysis (ABA), speech therapy, occupational therapy, and developmental relationship-based approaches like DIR/Floortime. Social skills training, cognitive behavioral therapy, and parent-mediated interventions are also beneficial. The most effective approach is often a combination tailored to the child\'s specific needs and may change as the child develops.',
          ),
          _buildFaqItem(
            question: 'Will my child with autism be able to attend regular school?',
            answer: 'Many children with autism do attend regular schools, often with accommodations or support services. Educational placement depends on the child\'s individual needs and abilities. Options range from full inclusion in general education classrooms (sometimes with an aide) to special education classrooms within regular schools or specialized schools. Each child\'s educational plan should be individualized.',
          ),
          _buildFaqItem(
            question: 'Does autism affect intelligence?',
            answer: 'Autism and intellectual ability are separate dimensions. Some people with autism have above-average intelligence, some have average intelligence, and some have intellectual disability. Intelligence testing in autism can be challenging because communication differences may affect test performance. Many autistic individuals have uneven skill profiles, with strengths in some areas and challenges in others.',
          ),
          _buildFaqItem(
            question: 'Will my child outgrow autism?',
            answer: 'Autism is a lifelong neurodevelopmental condition. However, with appropriate interventions, many children show significant improvement in symptoms and functioning. Some children who receive early intensive intervention may progress to the point where they no longer meet the criteria for autism diagnosis, though they may retain some characteristics. Development continues throughout life, and many autistic individuals learn to manage challenges effectively.',
          ),
          _buildFaqItem(
            question: 'How can I help my child\'s development while waiting for professional services?',
            answer: 'Engage in play-based activities that follow your child\'s interests. Narrate your activities and your child\'s actions. Create opportunities for communication by positioning desired items in sight but out of reach. Establish predictable routines. Limit screen time and increase face-to-face interaction. Join parent support groups to learn strategies from other families. Read books about child development and autism. Most importantly, enjoy your relationship with your child.',
          ),
          _buildFaqItem(
            question: 'How do I explain autism to my child\'s siblings?',
            answer: 'Use age-appropriate, concrete explanations. Emphasize that autism is just one aspect of their sibling, not their whole identity. Acknowledge the challenges while highlighting strengths. Validate siblings\' feelings, including difficult ones like frustration or jealousy. Create special time with each child. Include siblings in some therapy sessions when appropriate to learn helpful strategies. Consider sibling support groups where they can connect with peers in similar situations.',
          ),
          _buildFaqItem(
            question: 'Can diet affect autism symptoms?',
            answer: 'While some families report improvements with dietary changes, scientific evidence for specific diets affecting core autism symptoms is limited. Some children with autism have gastrointestinal issues or food sensitivities that, when addressed, may improve comfort and behavior. Consult with healthcare providers before making significant dietary changes. Ensure nutritional needs are met, especially if restricting food groups. Focus on overall healthy eating patterns rather than restrictive diets.',
          ),
          _buildFaqItem(
            question: 'What financial assistance is available for autism services?',
            answer: 'Options may include health insurance coverage (private, Medicaid, CHIP), early intervention programs (often at no or reduced cost for children under 3), school-based services (free through public education), Supplemental Security Income (SSI), Medicaid waivers, state-specific autism insurance mandates, nonprofit organization grants, flexible spending accounts, and health savings accounts. A social worker or case manager can help navigate these resources.',
          ),
        ],
      ),
    );
  }

  Widget _buildResourceBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCategory({
    required String title,
    required String description,
    required List<ServiceInfo> services,
  }) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          ...services.map((service) => _buildServiceItem(service)).toList(),
        ],
      ),
    );
  }

  Widget _buildServiceItem(ServiceInfo service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            service.description,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.phone,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                service.contact,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.language,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                service.website,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem({
    required String question,
    required String answer,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        expandedAlignment: Alignment.centerLeft,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        collapsedBackgroundColor: Colors.white,
        backgroundColor: Colors.white,
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          question,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
        children: [
          Text(
            answer,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceInfo {
  final String name;
  final String description;
  final String contact;
  final String website;

  ServiceInfo({
    required this.name,
    required this.description,
    required this.contact,
    required this.website,
  });
} 