import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ramadan_assistant/core/constants/umrah_duas.dart';
import 'package:ramadan_assistant/core/extensions/context_extensions.dart';
import 'package:ramadan_assistant/data/local/database/app_database.dart';
import 'package:ramadan_assistant/presentation/blocs/umrah_guide_bloc.dart';
import 'package:ramadan_assistant/presentation/blocs/umrah_guide_event.dart';
import 'package:ramadan_assistant/presentation/blocs/umrah_guide_state.dart';
import 'package:ramadan_assistant/presentation/widgets/dua_widget.dart';

class UmrahGuideView extends StatefulWidget {
  const UmrahGuideView({super.key});

  @override
  State<UmrahGuideView> createState() => _UmrahGuideViewState();
}

class _UmrahGuideViewState extends State<UmrahGuideView> {
  // States for Interactive Umrah
  int _tawafCircuits = 0;
  int _saiLaps = 0;
  bool _isPrayedAtMaqam = false;
  bool _isDrunkZamzam = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text('umrah_title'.tr()),
        // backgroundColor: context.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'refresh_tooltip'.tr(),
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _tawafCircuits = 0;
                _saiLaps = 0;
                _isPrayedAtMaqam = false;
                _isDrunkZamzam = false;
              });
              context.read<UmrahGuideBloc>().add(ResetUmrahProgress());
            },
          ),
        ],
      ),
      body: BlocBuilder<UmrahGuideBloc, UmrahGuideState>(
        builder: (context, state) {
          if (state is UmrahGuideInitial || state is UmrahGuideLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UmrahGuideLoaded) {
            return _buildStepList(context, state.progress);
          } else if (state is UmrahGuideError) {
            return Center(
              child: Text('error_prefix'.tr(args: [state.message])),
            );
          }
          return Center(child: Text('something_went_wrong'.tr()));
        },
      ),
    );
  }

  Widget _buildStepList(BuildContext context, List<UmrahProgressData> steps) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
        final isNext =
            !step.completed && (index == 0 || steps[index - 1].completed);

        return Card(
          margin: const EdgeInsets.only(bottom: 20),
          elevation: isNext ? 8 : 2,
          color: context.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: isNext
                ? BorderSide(color: context.secondaryColor, width: 2)
                : BorderSide.none,
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: step.completed
                    ? Colors.green
                    : (isNext
                          ? context.secondaryColor
                          : Colors.grey.withValues(alpha: 0.2)),
                child: step.completed
                    ? const Icon(Icons.check, color: Colors.white)
                    : (index + 1 >= 3 && index + 1 <= 5)
                    ? SvgPicture.asset(
                        'assets/${index + 1}.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          isNext ? context.onSecondaryColor : Colors.grey,
                          BlendMode.srcIn,
                        ),
                      )
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isNext
                              ? context.onSecondaryColor
                              : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              title: Text(
                step.step.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: step.completed ? Colors.grey : context.onSurfaceColor,
                ),
              ),
              subtitle: Text(
                step.completed
                    ? 'completed'.tr()
                    : (isNext ? 'current_stage'.tr() : 'waiting'.tr()),
                style: TextStyle(
                  color: isNext ? context.primaryColor : Colors.grey,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'guidelines_title'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: context.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._buildGuidelineWidgets(
                        context,
                        step.step,
                        step.completed,
                      ),
                      const SizedBox(height: 12),
                      if (step.step == 'الإحرام') ...[
                        OutlinedButton.icon(
                          onPressed: () => _showIshtiratDialog(context),
                          icon: const Icon(Icons.info_outline),
                          label: Text('ishtirat_dua'.tr()),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.primaryColor,
                            side: BorderSide(color: context.primaryColor),
                          ),
                        ),
                      ],
                      if (step.step == 'الطواف' || step.step == 'السعي') ...[
                        OutlinedButton.icon(
                          onPressed: () =>
                              _showComprehensiveDuasDialog(context, step.step),
                          icon: const Icon(Icons.menu_book),
                          label: Text(
                            step.step == 'السعي'
                                ? 'أدعية السعي الشاملة'
                                : 'أدعية الطواف الشاملة',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.secondaryColor,
                            side: BorderSide(color: context.secondaryColor),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      if (step.step == 'السعي') ...[
                        Text(
                          'dhikr_standing'.tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DuaWidget(
                          arabicText:
                              'اللهُ أَكْبَر، اللهُ أَكْبَر، اللهُ أَكْبَر. لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ. لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ، أَنْجَزَ وَعْدَهُ، وَنَصَرَ عَبْدَهُ، وَهَزَمَ الْأَعْزَابَ وَحْدَهُ.',
                          translation: 'dhikr_safa_marwa_standing_trans'.tr(),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'dhikr_walking'.tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DuaWidget(
                          arabicText:
                              'رَبَّنَا آتِنَا فِي الدِّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ.',
                          translation: 'dua_rabbana_atina_trans'.tr(),
                        ),
                        const SizedBox(height: 12),
                        DuaWidget(
                          arabicText:
                              'رَبِّ اغْفِرْ وَارْحَمْ، وَتَجَاوَزْ عَمَّا تَعْلَمُ، إِنَّكَ أَنْتَ الْأَعَزُّ الْأَكْرَمُ.',
                          translation: 'dua_rabbi_ighfir_trans'.tr(),
                        ),
                        const SizedBox(height: 12),
                        DuaWidget(
                          arabicText:
                              'اللهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى وَالتُّقَى وَالْعَفَافَ وَالْغِنَى.',
                          translation: 'dua_allahumma_inni_asaluka_trans'.tr(),
                        ),
                      ] else if (_getDuaArabic(step.step).isNotEmpty) ...[
                        Text(
                          'adhkar_title'.tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DuaWidget(
                          arabicText: _getDuaArabic(step.step),
                          translation: _getDuaTranslation(step.step),
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (!step.completed && isNext)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _canCompleteStep(step.step)
                                ? () {
                                    context.read<UmrahGuideBloc>().add(
                                      CompleteUmrahStep(step.id),
                                    );
                                    if (index == steps.length - 1) {
                                      _showCompletionDialog(context);
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _canCompleteStep(step.step)
                                  ? context.primaryColor
                                  : Colors.grey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              step.step == 'الطواف' &&
                                      !_canCompleteStep(step.step)
                                  ? 'complete_tawaf_first'.tr()
                                  : 'complete_button'.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _canCompleteStep(String step) {
    if (step == 'الطواف') {
      return _tawafCircuits == 7 && _isPrayedAtMaqam && _isDrunkZamzam;
    }
    if (step == 'السعي') {
      return _saiLaps == 7;
    }
    return true;
  }

  List<Widget> _buildGuidelineWidgets(
    BuildContext context,
    String step,
    bool completed,
  ) {
    final points = _getGuidelinePoints(step);

    return List.generate(points.length, (index) {
      final point = points[index];

      // Interactive Counter for Tawaf
      if (step == 'الطواف' && index == 0 && !completed) {
        return _buildTawafCounter(context, point);
      }

      // Checkboxes for Tawaf tasks
      if (step == 'الطواف' && index == 3 && !completed) {
        return _buildTawafCheckbox(point, _isPrayedAtMaqam, (val) {
          setState(() => _isPrayedAtMaqam = val ?? false);
        });
      }
      if (step == 'الطواف' && index == 4 && !completed) {
        return _buildTawafCheckbox(point, _isDrunkZamzam, (val) {
          setState(() => _isDrunkZamzam = val ?? false);
        });
      }

      // Interactive Counter for Sa'i
      if (step == 'السعي' && index == 0 && !completed) {
        return _buildSaiCounter(context, point);
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: context.primaryColor,
              ),
            ),
            Expanded(child: Text(point, style: const TextStyle(height: 1.5))),
          ],
        ),
      );
    });
  }

  Widget _buildTawafCounter(BuildContext context, String text) {
    return _buildCounter(
      context,
      text,
      _tawafCircuits,
      7,
      (val) => setState(() => _tawafCircuits = val),
      'tawaf_done'.tr(),
    );
  }

  Widget _buildSaiCounter(BuildContext context, String text) {
    return _buildCounter(
      context,
      text,
      _saiLaps,
      7,
      (val) => setState(() => _saiLaps = val),
      'sai_done'.tr(),
    );
  }

  Widget _buildCounter(
    BuildContext context,
    String text,
    int current,
    int max,
    Function(int) onChanged,
    String successText,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.secondaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.secondaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: current > 0 ? () => onChanged(current - 1) : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: context.primaryColor,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '$current / $max',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: current < max ? () => onChanged(current + 1) : null,
                icon: const Icon(Icons.add_circle_outline),
                color: context.primaryColor,
              ),
            ],
          ),
          if (current == max)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                successText,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTawafCheckbox(
    String text,
    bool value,
    Function(bool?) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: value ? Colors.green.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CheckboxListTile(
        title: Text(text, style: const TextStyle(fontSize: 14)),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.green,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    );
  }

  List<String> _getGuidelinePoints(String step) {
    String keyPrefix = '';
    int count = 0;
    switch (step) {
      case 'الإحرام':
        keyPrefix = 'guide_ihram';
        count = 6;
        break;
      case 'دخول المسجد الحرام':
        keyPrefix = 'guide_entrance';
        count = 3;
        break;
      case 'الطواف':
        keyPrefix = 'guide_tawaf';
        count = 5;
        break;
      case 'السعي':
        keyPrefix = 'guide_sai';
        count = 5;
        break;
      case 'التقصير أو الحلق والتحلل':
        keyPrefix = 'guide_tahlul';
        count = 3;
        break;
    }

    if (keyPrefix.isEmpty) return ['Follow the Sunnah.'];
    return List.generate(count, (i) => '${keyPrefix}_${i + 1}'.tr());
  }

  String _getDuaArabic(String step) {
    switch (step) {
      case 'الإحرام':
        return 'لَبَّيْكَ اللَّهُمَّ عُمْرَةً. لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لاَ شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لاَ شَرِيكَ لَكَ.';
      case 'الطواف':
        return 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ.';
      case 'السعي':
        return 'إِنَّ الصَّفَا وَالْمَرْوَةَ مِنْ شَعَائِرِ اللَّهِ فَمَنْ حَجَّ الْبَيْتَ أَوِ اعْتَمَرَ فَلَا جُنَاحَ عَلَيْهِ أَنْ يَطَّوَّفَ بِهِمَا وَمَنْ تَطَوَّعَ خَيْرًا فَإِنَّ اللَّهَ شَاكِرٌ عَلِيمٌ.';
      default:
        return '';
    }
  }

  String _getDuaTranslation(String step) {
    String key = '';
    switch (step) {
      case 'الإحرام':
        key = 'dua_ihram_trans';
        break;
      case 'الطواف':
        key = 'dua_tawaf_trans';
        break;
      case 'السعي':
        key = 'dua_sai_trans';
        break;
    }
    if (key.isEmpty) return '';

    final manualTranslation = key.tr();
    return manualTranslation;
  }

  void _showIshtiratDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.surfaceColor,
        title: const Text('دعاء الاشتراط', textAlign: TextAlign.center),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                UmrahDuas.ishtiratInfo,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),
              DuaWidget(
                arabicText: UmrahDuas.ishtiratFull,
                translation: UmrahDuas.ishtirat.translation ?? '',
              ),
              const SizedBox(height: 10),
              Text(
                'تقوله عند نية الدخول في الإحرام',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('close'.tr()),
          ),
        ],
      ),
    );
  }

  void _showComprehensiveDuasDialog(BuildContext context, String step) {
    final duas = UmrahDuas.saiDuas;
    final categories = duas.map((e) => e.category).toSet().toList();

    showDialog(
      context: context,
      builder: (context) => DefaultTabController(
        length: categories.length,
        child: AlertDialog(
          backgroundColor: context.surfaceColor,
          title: Text(
            step == 'السعي' ? 'أدعية السعي الشاملة' : 'أدعية الطواف الشاملة',
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  labelColor: context.primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: context.primaryColor,
                  tabs: categories.map((cat) => Tab(text: cat)).toList(),
                ),
                Expanded(
                  child: TabBarView(
                    children: categories.map((cat) {
                      final catDuas = duas
                          .where((d) => d.category == cat)
                          .toList();
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        itemCount: catDuas.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return DuaWidget(
                            arabicText: catDuas[index].arabic,
                            translation: '', // No translation provided for all
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('close'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.surfaceColor,
        title: Text('accept_title'.tr(), textAlign: TextAlign.center),
        content: Text('accept_message'.tr(), textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('close'.tr()),
          ),
        ],
      ),
    );
  }
}
