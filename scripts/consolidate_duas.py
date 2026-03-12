import json
import os

def flatten_duas(source_file):
    # Try different encodings
    for encoding in ['utf-8-sig', 'utf-16', 'utf-8']:
        try:
            with open(source_file, 'r', encoding=encoding) as f:
                data = json.load(f)
            break
        except Exception as e:
            continue
    else:
        raise Exception(f"Could not decode {source_file}")
    
    flattened = []
    for item in data:
        category = item.get('category', 'عام')
        for d in item.get('duaa', []):
            text = d.get('text', '')
            source_info = d.get('source', {})
            
            # Extract a simple source string
            source_str = ""
            if source_info.get('type') == 'quran':
                refs = source_info.get('references', [])
                if refs:
                    ref = refs[0]
                    surah = ref.get('surah', {}).get('name', '')
                    ayah = ref.get('ayah', {}).get('from', '')
                    source_str = f"سورة {surah} - {ayah}"
            elif source_info.get('type') == 'hadith':
                refs = source_info.get('references', [])
                if refs:
                    ref = refs[0]
                    book = ref.get('book', '')
                    num = ref.get('numberOrPage', '')
                    source_str = f"{book} - {num}"
            
            flattened.append({
                "category": category,
                "arabic": text,
                "source": source_str
            })
    return flattened

# Umrah Duas from the app
umrah_duas = [
    {"category": "إحرام", "arabic": "اللهمَّ مَحِلِّي حَيْثُ حَبَسْتَنِي", "source": "دعاء الاشتراط"},
    {"category": "أذكار ثابتة في الطواف", "arabic": "بسم الله، اللهُ أكبر، اللهم إيماناً بك وتصديقاً بكتابك، ووفاءً بعهدك، واتباعاً لسنة نبيك محمد ﷺ", "source": "عند الحجر الأسود - بداية كل شوط"},
    {"category": "أذكار ثابتة في الطواف", "arabic": "ربنا آتنا في الدنيا حسنة وفي الآخرة حسنة وقنا عذاب النار", "source": "بين الركن اليماني والحجر الأسود"},
    {"category": "أذكار ثابتة في الطواف", "arabic": "اللهم اغفر وارحم، واعف عما تعلم، وأنت الأعز الأكرم", "source": "ذكر عام أثناء الطواف"},
    {"category": "آية السعي", "arabic": "إِنَّ الصَّفَا وَالْمَرْوَةَ مِن شَعَائِرِ اللَّهِ ۖ فَمَنْ حَجَّ الْبَيْتَ أَوِ اعْتَمَرَ فَلَا جُنَاحَ عَلَيْهِ أَن يَطَّوَّفَ بِهِمَا ۚ وَمَن تَطَوَّعَ خَيْرًا فَإِنَّ اللَّهَ شَاكِرٌ عَلِيمٌ", "source": "سورة البقرة - 158"},
    {"category": "التكبير والتهليل", "arabic": "اللَّهُ أَكْبَرُ، اللَّهُ أَكْبَرُ، اللَّهُ أَكْبَرُ، لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَىْءٍ قَدِيرٌ، لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ أَنْجَزَ وَعْدَهُ، وَنَصَرَ عَبْدَهُ، وَهَزَمَ الأَحْزَابَ وَحْدَهُ", "source": "صحيح مسلم - يقال عند الوقوف على الصفا والمروة"}
]

# Adding some unique ones from saiDuas
more_umrah = [
    {"category": "الشوط الأول", "arabic": "اللهم اجعل سعيي مشكورًا، وذنبي مغفورًا، وعملي مقبولًا، وتجارتي لن تبور"},
    {"category": "أدعية مأثورة", "arabic": "اللهم إنك عفوٌّ تُحِبُّ العفوَ فاعفُ عني", "source": "صحيح الترمذي"},
    {"category": "أدعية مأثورة", "arabic": "اللهم إني أسألك الهدى والتقى والعفاف والغنى", "source": "صحيح مسلم"},
    {"category": "أدعية جامعة", "arabic": "اللهم أصلح لي ديني الذي هو عصمة أمري، وأصلح لي دنياي التي فيها معاشي، وأصلح لي آخرتي التي فيها معادي، واجعل الحياة زيادة لي في كل خير، والموت راحة لي من كل شر", "source": "دعاء إصلاح الدنيا والآخرة"},
    {"category": "سيد الاستغفار", "arabic": "اللهم أنت ربي لا إله إلا أنت، خلقتني وأنا عبدك، وأنا على عهدك ووعدك ما استطعت، أعوذ بك من شر ما صنعت، أبوء لك بنعمتك علي وأبوء بذنبي فاغفر لي، فإنه لا يغفر الذنوب إلا أنت", "source": "صحيح البخاري"},
    {"category": "دعاء الوداع", "arabic": "اللهم ودّاً وتكراراً، لا وداعاً، اللهم لا تجعل هذا آخر عهدي بزيارة بيتك الكريم، وارزقني الحج والعمرة مراتٍ عديدة وأزمنة مديدة", "source": "دعاء وداع البيت"}
]

source_flattened = flatten_duas('assets/data/duas_source.json')

final_data = {
    "duas": umrah_duas + more_umrah + source_flattened
}

with open('assets/data/duas.json', 'w', encoding='utf-8') as f:
    json.dump(final_data, f, ensure_ascii=False, indent=2)

print(f"Successfully generated duas.json with {len(final_data['duas'])} duas.")
