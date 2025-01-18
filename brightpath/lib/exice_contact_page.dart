// brightpath/lib/excise_contact_page.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ExciseContactPage extends StatefulWidget {
  @override
  _ExciseContactPageState createState() => _ExciseContactPageState();
}

class _ExciseContactPageState extends State<ExciseContactPage> {
  String? selectedRegion;
  String? selectedDistrict;
  int? _hoveredIndex;
  int _selectedIndex = 2;

  final Map<String, List<String>> regions = {
    'Southern Region': [
      'Thiruvananthapuram',
      'Kollam',
      'Pathanamthitta',
      'Alappuzha',
      'Kottayam',
    ],
    'Central Region': [
      'Idukki',
      'Ernakulam',
      'Thrissur',
      'Palakkad',
      'S.E.A.R.C.',
    ],
    'North Zone': [
      'Malappuram',
      'Kozhikode',
      'Wayanad',
      'Kannur',
      'Kasaragod',
    ],
  };

  Map<String, List<Map<String, String>>> contactDetails = {
    'Ernakulam': [
      {
        'name': 'Deputy Excise Commissioner',
        'phone': '0484-2390657',
        'mobile': '9447178059',
        'email': 'decekm.exc@kerala.gov.in',
        'address': 'Excise Division Office, Excise Zone Building, Kacheripady, Ernakulam - 682018',
      },
      {
        'name': 'Assistant Excise Commissioner E.E. & A.N.S.S.',
        'phone': '0484-2627480',
        'mobile': '9496002867',
        'email': 'aecekm.exc@kerala.gov.in',
        'address': 'Excise Zonal Building, Kacheripady, Ernakulam - 682018',
      },
      {
        'name': 'Excise Enforcement & Anti-Narcotics Special Squad',
        'phone': '0484-2627480',
        'ci': '9400069550',
        'ei': '9400069551',
        'email': 'eeanssekm.exc@kerala.gov.in',
        'address': 'Ernakulam, Excise Zonal Building, Kacheripady, Ernakulam - 682018',
      },
      {
        'name': 'Excise Circle Office Ernakulam',
        'phone': '0484-2393121',
        'ci': '9400069552',
        'ei': '9400069553',
        'email': 'ecoekm.exc@kerala.gov.in',
        'address': 'Near North Railway Station, Ernakulam - 682018',
      },
      {
        'name': 'Excise Circle Office Kochi',
        'phone': '0484-2215120',
        'ci': '9400069554',
        'ei': '9400069556',
        'email': 'ecokochi.exc@kerala.gov.in',
        'address': 'Opposite Santacruz School Ground, Njaliparamba, Kochi - 682001',
      },
      {
        'name': 'Excise Circle Office North Paravur',
        'phone': '0484-2443187',
        'ci': '9400069557',
        'ei': '9400069558',
        'email': 'econpvr.exc@kerala.gov.in',
        'address': 'Mini Civil Station, North Paravur, Ernakulam - 683513',
      },
      {
        'name': 'Excise Circle Office Kunnathunadu',
        'phone': '0484-2591203',
        'ci': '9400069559',
        'email': 'ecokntd.exc@kerala.gov.in',
        'address': 'P.P. Road Junction, Perumbavoor, Ernakulam - 683542',
      },
      {
        'name': 'Excise Circle Office Aluva',
        'phone': '0484-2623655',
        'ci': '9400069560',
        'ei': '9400069561',
        'email': 'ecoalva.exc@kerala.gov.in',
        'address': 'Near Mini Civil Station, Civil Station Road, Aluva - 683101',
      },
      {
        'name': 'Excise Circle Office Kothamangalam',
        'phone': '0485-2824419',
        'ci': '9400069562',
        'ei': '9400069563',
        'email': 'ecoktmglm.exc@kerala.gov.in',
        'address': 'Thankalam Junction, Kothamangalam, Ernakulam - 686691',
      },
      {
        'name': 'Excise Circle Office Muvattupuzha',
        'phone': '0485-2832623',
        'ci': '9400069564',
        'email': 'ecomvpa.exc@kerala.gov.in',
        'address': 'Post Office Junction, Muvattupuzha, Ernakulam - 686661',
      },
      {
        'name': 'Excise Range Office Ernakulam',
        'phone': '0484-2392283',
        'ei': '9400069565',
        'aei': '9496499392',
        'email': 'eroekm.exc@kerala.gov.in',
        'address': 'Excise Range Building, Kacheripady, Ernakulam - 682018',
      },
      {
        'name': 'Excise Range Office Tripunithura',
        'phone': '0484-2785060',
        'ei': '9400069566',
        'email': 'erotrpna.exc@kerala.gov.in',
        'address': 'Mini Civil Station, Tripunithura, Ernakulam - 682301',
      },
      {
        'name': 'Excise Range Office Mattancherry',
        'phone': '0484-2221998',
        'ei': '9400069567',
        'email': 'eromtnry.exc@kerala.gov.in',
        'address': 'Anavathil, Mattancherry, Ernakulam - 682002',
      },
      {
        'name': 'Excise Range Office Njarakkal',
        'phone': '0484-2499297',
        'ei': '9400069568',
        'aei': '9496499410',
        'email': 'eronjkl.exc@kerala.gov.in',
        'address': 'Public Office Complex, Mampilly, Njarakkal, Ernakulam - 682505',
      },
      {
        'name': 'Excise Range Office Angamaly',
        'phone': '0484-2458484',
        'ei': '9400069572',
        'aei': '9496499422',
        'email': 'eroagmy.exc@kerala.gov.in',
        'address': 'T.B. Junction, Angamaly, Ernakulam - 683572',
      },
      {
        'name': 'Excise Range Office Kalady',
        'phone': '0484-2461326',
        'ei': '9400069573',
        'aei': '9496499426',
        'email': 'erokoy.exc@kerala.gov.in',
        'address': 'Malayattoor Road, Near Sanskrit University, Kalady, Ernakulam - 683574',
      },
      {
        'name': 'Excise Range Office Perumbavoor',
        'phone': '0484-2590831',
        'ei': '9400069574',
        'aei': '9496499414',
        'email': 'eropbvr.exc@kerala.gov.in',
        'address': 'P.P. Road Junction, Perumbavoor, Ernakulam - 683542',
      },
      {
        'name': 'Excise Range Office Mamala',
        'phone': '0484-2786848',
        'ei': '9400069575',
        'email': 'eromla.exc@kerala.gov.in',
        'address': 'Near KEL, Mamala, Ernakulam - 682305',
      },
      {
        'name': 'Excise Range Office Muvattupuzha',
        'phone': '0485-2836717',
        'ei': '9400069576',
        'aei': '9496499438',
        'email': 'eromvpa.exc@kerala.gov.in',
        'address': 'Post Office Junction, Muvattupuzha, Ernakulam - 686661',
      },
      {
        'name': 'Excise Range Office Piravom',
        'phone': '0485-2241573',
        'ei': '9400069577',
        'email': 'eropvm.exc@kerala.gov.in',
        'address': 'Piravom P.O., Ernakulam - 686664',
      },
      {
        'name': 'Excise Range Office Kothamangalam',
        'phone': '0485-2826460',
        'ei': '9400069578',
        'aei': '9496499431',
        'email': 'eroktglm.exc@kerala.gov.in',
        'address': 'Thangalam Junction, Kothamangalam, Ernakulam - 686691',
      },
      {
        'name': 'Excise Range Office Kuttampuzha',
        'phone': '0485-2572861',
        'ei': '9400069579',
        'aei': '9496499435',
        'email': 'eroktmpa.exc@kerala.gov.in',
        'address': 'Punnekal, Keerampara P.O., Ernakulam - 686681',
      },
      {
        'name': 'K.S.B.C.F.L.9 Warehouse, Tripunithura',
        'phone': '0484-2302130',
        'ci': '',
        'email': 'tpraksbc.exc@kerala.gov.in',
        'address': 'Petta Junction, Tripunithura, Ernakulam - 682038',
      },
      {
        'name': 'K.S.B.C. FL.9 Warehouse, Aluva',
        'phone': '0484-2838400',
        'ci': '',
        'email': 'aluvaksbc.exc@kerala.gov.in',
        'address': 'Choondi, Aluva, Ernakulam - 683112',
      },
      {
        'name': 'K.S.B.C. FL.9 Warehouse, Vengola',
        'phone': '0484-2595755',
        'ci': '',
        'email': 'pbvrksbc.exc@kerala.gov.in',
        'address': 'Company Road, Vengola, Ernakulam - 683554',
      },
      {
        'name': 'Indo Scottish Brand Distillery, Kochi',
        'phone': '0484-2223424',
        'ei': '',
        'email': 'eiisbdekm.exc@kerala.gov.in',
        'address': 'Karuvelipady, Kochi - 682005',
      },
      {
        'name': 'Devikulam Distilleries Limited, Kakkanad',
        'phone': '0484-2982552',
        'ei': '',
        'email': 'eiddk.exc@kerala.gov.in',
        'address': 'Kusumagiri P.O., Parakkamkulam, Kakkanad, Ernakulam - 682030',
      },
      {
        'name': 'Excise Intelligence & Investigation Bureau',
        'phone': '0484-2393430',
        'ei': '9400069580',
        'email': 'eiibekm.exc@kerala.gov.in',
        'address': 'Excise Sector Building, Kacheripady, Ernakulam - 682018',
      },
      {
        'name': 'North Paravur Mini Civil Station',
        'phone': '0484-2441280',
        'ei': '9400069569',
        'email': 'eronpvr.exc@kerala.gov.in',
        'address': 'North Paravur, Ernakulam - 683513',
      },
      {
        'name': 'Excise Range Office Varappuzha',
        'phone': '0484-2511045',
        'ei': '9400069570',
        'email': 'erovpa.exc@kerala.gov.in',
        'address': 'Opposite Christ Nagar Church, Varappuzha, Ernakulam - 683517',
      },
      {
        'name': 'Excise Range Office Aluva',
        'phone': '0484-2621089',
        'ei': '9400069571',
        'email': 'eroalva.exc@kerala.gov.in',
        'address': 'Near Mini Civil Station, Civil Station Road, Aluva, Ernakulam - 683101',
      },
    ],
    'Kollam': [
      {
        'name': 'Deputy Excise Commissioner',
        'phone': '0474-2745648',
        'mobile': '9447178054',
        'email': 'decklm.exc@kerala.gov.in',
        'address': 'Excise Division Office, Excise Complex, 1st Floor, A Block, Chinnakada, Kollam - 691001',
      },
      {
        'name': 'Assistant Excise Commissioner',
        'phone': '0474-2767822',
        'mobile': '9496002862',
        'email': 'aecklm.exc@kerala.gov.in',
        'address': 'Excise Enforcement & Anti-Narcotics Special Squad, Excise Complex, 2nd Floor, A Block, Chinnakada, Kollam - 691001',
      },
      {
        'name': 'Excise Enforcement & Anti Narcotics Special Squad',
        'phone': '0474-2767822',
        'ci': '9400069439',
        'ei': '9400069440',
        'email': 'eeanssklm.exc@kerala.gov.in',
        'address': 'Excise Complex, 2nd Floor, A Block, Chinnakada, Kollam - 691001',
      },
      {
        'name': 'Excise Circle Office Kollam',
        'phone': '0474-2768671',
        'ci': '9400069441',
        'ei': '9400069442',
        'email': 'ecoklm.exc@kerala.gov.in',
        'address': 'Excise Complex, Ground Floor, A Block, Chinnakada, Kollam - 691001',
      },
      {
        'name': 'Excise Circle Office Karunagappally',
        'phone': '0476-2631771',
        'ci': '9400069443',
        'ei': '9400069445',
        'email': 'ecokngply.exc@kerala.gov.in',
        'address': 'Mozhiyil House, Pata South, Karunagappally - 690518',
      },
      {
        'name': 'Excise Circle Office Near Kottarakkara',
        'phone': '0474-2452639',
        'ci': '9400069446',
        'ei': '9400069447',
        'email': 'ecoktra.exc@kerala.gov.in',
        'address': 'Railway Station, Kottarakkara - 691506',
      },
      {
        'name': 'Excise Circle Office Punalur',
        'phone': '0475-2222318',
        'ci': '9400069450',
        'ei': '9400069451',
        'email': 'ecopnlr.exc@kerala.gov.in',
        'address': 'Velutheril House, Tholikode, Punalur - 691333',
      },
      {
        'name': 'Excise Circle Office Kunnathur',
        'phone': '0476-2835303',
        'ci': '9400069448',
        'ei': '9400069449',
        'email': 'ecokntr.exc@kerala.gov.in',
        'address': 'Near KWA Filter House, Manakkara, Sasthamkotta - 690521',
      },
      {
        'name': 'Excise Circle Office Pathanapuram',
        'phone': '0475-2354699',
        'email': 'ecoptpm.exc@kerala.gov.in',
        'address': 'Kallumkadavu Panchayat Building, Pathanapuram - 689695',
      },
      {
        'name': 'Excise Range Office Kollam',
        'phone': '0474-2760728',
        'ei': '9400069454',
        'aei': '9496499101',
        'email': 'eroklm.exc@kerala.gov.in',
        'address': 'Excise Complex, Ground Floor, A Block, Chinnakada, Kollam - 691001',
      },
      {
        'name': 'Excise Range Office Karunagapally',
        'phone': '0476-2630831',
        'ei': '9400069456',
        'email': 'erokngply.exc@kerala.gov.in',
        'address': 'Civil Station West Side, Karunagappally - 690518',
      },
      {
        'name': 'Excise Range Office Kottarakkara',
        'phone': '0474-2450265',
        'ei': '9400069458',
        'aei': '9496499110',
        'email': 'eroktkra.exc@kerala.gov.in',
        'address': 'Thottamukku, ETC Road, Thrikannamangalam, Kottarakkara - 691506',
      },
      {
        'name': 'Excise Range Office Chathannur',
        'phone': '0474-2596667',
        'ei': '9400069455',
        'email': 'eroctnr.exc@kerala.gov.in',
        'address': 'Mini Civil Station, Chathannur - 691572',
      },
      {
        'name': 'Excise Range Office Pathanapuram',
        'phone': '0475-2321560',
        'ei': '9400069461',
        'aei': '9496499130',
        'email': 'eroptnpm.exc@kerala.gov.in',
        'address': 'VP XIX/685-690, Kunnikode, Pathanapuram - 691508',
      },
      {
        'name': 'Excise Range Office Sasthamkotta',
        'phone': '0476-2833470',
        'ei': '9400069457',
        'email': 'erosasta.exc@kerala.gov.in',
        'address': 'Poovanalazikat House, Manakkara, Sasthamkotta - 690521',
      },
      {
        'name': 'Excise Range Office Near Chadayamangalam',
        'phone': '0474-2475191',
        'ei': '9400069459',
        'email': 'erochmglm.exc@kerala.gov.in',
        'address': 'Panchayat Office, Chadayamangalam - 691534',
      },
      {
        'name': 'Excise Range Office Anchal',
        'phone': '0475-2274445',
        'ei': '9400069462',
        'aei': '9496499125',
        'email': 'eroacl.exc@kerala.gov.in',
        'address': 'Panayanchery, Anchal - 691306',
      },
      {
        'name': 'Excise Range Office Ezhukon',
        'phone': '0474-2482333',
        'ei': '9400069460',
        'email': 'eroekn.exc@kerala.gov.in',
        'address': 'Ezhukon, Pochakonam, Ezhukon - 691505',
      },
      {
        'name': 'Excise Check Post Aryankav',
        'phone': '0475-2211688',
        'ci': '9400069452',
        'ei': '9400069453',
        'email': 'akvecp.exc@kerala.gov.in',
        'address': 'Aryankav - 691316',
      },
      {
        'name': 'Excise Check Post Achankovil',
        'phone': '',
        'ei': '9496499140',
        'email': '',
        'address': 'Near Ayyappa Temple, Achankovil - 689696',
      },
      {
        'name': 'K.S.B.C. FL.9 Warehouse, Kollam',
        'phone': '0474-2710029',
        'ci': '',
        'email': 'klmksbc.exc@kerala.gov.in',
        'address': 'Karikode, Kollam - 691005',
      },
      {
        'name': 'K.S.B.C. FL.9 Warehouse, Kottarakkara',
        'phone': '0474-2453741',
        'ci': '',
        'email': 'ktraksbc.exc@kerala.gov.in',
        'address': 'Pulamon, Kottarakkara - 691533',
      },
      {
        'name': 'Murugan Pharma Punalur',
        'phone': '0475-2223034',
        'ei': '',
        'email': 'eimpp.exc@kerala.gov.in',
        'address': 'Bharanikavu, Punalur - 691305',
      },
      {
        'name': 'Excise Intelligence & Investigation Bureau',
        'phone': '0474-2742277',
        'ei': '9400069463',
        'email': 'eiibklm.exc@kerala.gov.in',
        'address': 'Excise Complex, 2nd Floor, A Block, Chinnakada, Kollam - 691001',
      },
    ],
    'Pathanamthitta': [
      {
        'name': 'Deputy Excise Commissioner',
        'phone': '0468-2222873',
        'mobile': '9447178055',
        'email': 'decpta.exc@kerala.gov.in',
        'address': 'Excise Division Office, 1st Floor, Devaswom Board Building, Pathanamthitta - 689645',
      },
      {
        'name': 'Assistant Excise Commissioner',
        'phone': '0468-2351000',
        'mobile': '9496002863',
        'email': 'aecpta.exc@kerala.gov.in',
        'address': 'Excise Enforcement & Anti-Narcotics Special Squad, 2nd Floor, Panachikal Building No. 13/365-370, Omallur P.O., Pathanamthitta - 689647',
      },
      {
        'name': 'Excise Enforcement & Anti Narcotics Special Squad',
        'phone': '0468-2351000',
        'ci': '9400069473',
        'ei': '9400069474',
        'email': 'eeansspta.exc@kerala.gov.in',
        'address': '2nd Floor, Panachikal Building No. 13/365-370, Omallur P.O., Pathanamthitta - 689647',
      },
      {
        'name': 'Excise Circle Office Pathanamthitta',
        'phone': '0468-2222502',
        'ci': '9400069466',
        'ei': '9400069467',
        'email': 'ecopta.exc@kerala.gov.in',
        'address': 'Orukunni Building No. VII/13(11), Upper Vettipuram, Pathanamthitta - 689645',
      },
      {
        'name': 'Excise Circle Office Adoor',
        'phone': '04734-229395',
        'ci': '9400069464',
        'ei': '9400069465',
        'email': 'ecoadr.exc@kerala.gov.in',
        'address': 'Adoor Municipality Building No. 24/276/18, Adoor P.O., Pathanamthitta - 691523',
      },
      {
        'name': 'Excise Circle Office Ranni',
        'phone': '04735-228560',
        'ci': '9400069468',
        'ei': '9400069469',
        'email': 'ecorny.exc@kerala.gov.in',
        'address': 'Building No. 03/191, Patheroot House, Ranni P.O., Pathanamthitta - 689672',
      },
      {
        'name': 'Excise Circle Office Mallapally',
        'phone': '0469-2682540',
        'ci': '9400069470',
        'ei': '9400069471',
        'email': 'ecomlply.exc@kerala.gov.in',
        'address': 'Muttithottham Building No. 438, Mallapally P.O., Pathanamthitta - 689594',
      },
      {
        'name': 'Excise Circle Office Thiruvalla',
        'phone': '0469-2605684',
        'ci': '9400069472',
        'email': 'ecotvla.exc@kerala.gov.in',
        'address': 'Kerala State Housing Board Building, Revenue Tower, 3rd Floor, Thiruvalla - 689101',
      },
      {
        'name': 'Excise Range Office Pathanamthitta',
        'phone': '0468-2322235',
        'ei': '9400069476',
        'aei': '9496499160',
        'email': 'eropta.exc@kerala.gov.in',
        'address': '1st Floor, No. 22/68,69,70, Municipality Building Near Municipal Stadium, Pathanamthitta - 689645',
      },
      {
        'name': 'Excise Range Office Adoor',
        'phone': '04734-216050',
        'ei': '9400069475',
        'aei': '9496499176',
        'email': 'eroadr.exc@kerala.gov.in',
        'address': 'Building No. XVI-VII/18, Adoor Municipality, Parakkodi P.O., Adoor - 691554',
      },
      {
        'name': 'Excise Range Office Konni',
        'phone': '0468-2244546',
        'ei': '9400069477',
        'aei': '9496499164',
        'email': 'erokonni.exc@kerala.gov.in',
        'address': 'Poovallil House, Mangaram, Vakayar P.O., Konni - 689698',
      },
      {
        'name': 'Excise Range Office Chittar',
        'phone': '04735-251922',
        'ei': '9400069479',
        'email': 'erochittar.exc@kerala.gov.in',
        'address': 'No. 1/394, Maniyat Building, Madamon P.O., Vadasserikkara, Pathanamthitta - 689711',
      },
      {
        'name': 'Excise Range Office Ranni',
        'phone': '04735-229232',
        'ei': '9400069478',
        'email': 'eroranni.exc@kerala.gov.in',
        'address': 'Building No. 10,011/70, Parakkal House, Ranni P.O., Pathanamthitta - 689622',
      },
      {
        'name': 'Excise Range Office Mallapally',
        'phone': '0469-2683222',
        'ei': '9400069480',
        'email': 'eromlply.exc@kerala.gov.in',
        'address': '1st Floor, No. 04/424/18, Mallapally Municipality Building, Mallapally P.O., Pathanamthitta - 689585',
      },
      {
        'name': 'Excise Range Office Thiruvalla',
        'phone': '0469-2747632',
        'ei': '9400069481',
        'email': 'erotvla.exc@kerala.gov.in',
        'address': 'Thiruvalla Municipality, Building No. 16/358, Katode, Manchadi P.O., Thiruvalla - 689105',
      },
      {
        'name': 'K.S.B.C. FL.9 Warehouse, Pathanamthitta',
        'phone': '0468-2225772',
        'ci': '',
        'email': 'ptaksbc.exc@kerala.gov.in',
        'address': '24/146 Kodumthara, Pathanamthitta - 689645',
      },
      {
        'name': 'Travancore Sugars & Chemicals Limited',
        'phone': '0469-2610711/12',
        'ci': '',
        'email': 'citsctvla.exc@kerala.gov.in',
        'address': 'Pulikeezhu, Valanjavattom P.O., Thiruvalla - 691804',
      },
    ],
    'Alappuzha': [
      {
        'name': 'Deputy Excise Commissioner',
        'phone': '0477-2252049',
        'mobile': '9447178056',
        'email': 'decalpy.exc@kerala.gov.in',
        'address': 'Excise Division Office, Excise Complex, Iron Bridge P.O., Near General Hospital, Alappuzha - 688011',
      },
      {
        'name': 'Assistant Excise Commissioner E.E. & ANSS',
        'phone': '0477-2251639',
        'mobile': '9496002864',
        'email': 'aecalpy.exc@kerala.gov.in',
        'address': 'Excise Complex, 2nd Floor, Iron Bridge P.O., Near General Hospital, Alappuzha - 688011',
      },
      {
        'name': 'Excise Enforcement & Anti Narcotics Special Squad',
        'phone': '0477-2251639',
        'ci': '9400069494',
        'ei': '9400069495',
        'email': 'eeanssalpy.exc@kerala.gov.in',
        'address': 'Excise Complex, 2nd Floor, Iron Bridge P.O., Near General Hospital, Alappuzha - 688011',
      },
      {
        'name': 'Excise Circle Office Alappuzha',
        'phone': '0477-2230183',
        'ci': '9400069485',
        'ei': '9400069486',
        'email': 'ecoalpy.exc@kerala.gov.in',
        'address': 'Excise Complex, 2nd Floor, Iron Bridge P.O., Near General Hospital, Alappuzha - 688011',
      },
      {
        'name': 'Excise Circle Office Cherthala',
        'phone': '0478-2813126',
        'ci': '9400069483',
        'ei': '9400069484',
        'email': 'ecoctla.exc@kerala.gov.in',
        'address': 'Pilchulam Water Tank Junction, Varanad P.O., Alappuzha - 688539',
      },
      {
        'name': 'Excise Circle Office Kuttanad',
        'phone': '0477-2704833',
        'ci': '9400069487',
        'email': 'ecoktnd.exc@kerala.gov.in',
        'address': 'Ramankari P.O., Alappuzha - 689595',
      },
      {
        'name': 'Excise Circle Office Haripad',
        'phone': '0479-2412350',
        'ci': '9400069492',
        'ei': '9400069493',
        'email': 'ecohpd.exc@kerala.gov.in',
        'address': 'Haripad P.O., Alappuzha - 690514',
      },
      {
        'name': 'Excise Circle Office Mavelikkara',
        'phone': '0479-2340265',
        'ci': '9400069490',
        'ei': '9400069491',
        'email': 'ecomvka.exc@kerala.gov.in',
        'address': 'Thattarambalam P.O., Mavelikkara, Alappuzha - 690103',
      },
      {
        'name': 'Excise Circle Office Chengannur',
        'phone': '0479-2452415',
        'ci': '9400069488',
        'ei': '9400069489',
        'email': 'ecocgnr.exc@kerala.gov.in',
        'address': 'Puthenkavu P.O., Chengannur, Alappuzha - 680123',
      },
      {
        'name': 'Excise Range Office Alappuzha',
        'phone': '0477-2230182',
        'ei': '9400069498',
        'email': 'eroalpy.exc@kerala.gov.in',
        'address': 'Excise Complex, Iron Bridge P.O., Near General Hospital, Alappuzha - 688011',
      },
      {
        'name': 'Excise Range Office Kuthiyathode',
        'phone': '0478-2561966',
        'ei': '9400069496',
        'email': 'eroktyd.exc@kerala.gov.in',
        'address': 'Near SNGM College Junction, Valamangalam South P.O., Alappuzha - 688532',
      },
      {
        'name': 'Excise Range Office Kuttanad',
        'phone': '0477-2704851',
        'ei': '9400069499',
        'email': 'eroktnd.exc@kerala.gov.in',
        'address': 'Thekkekkara P.O., Alappuzha - 688503',
      },
      {
        'name': 'Excise Range Office Karthikappally',
        'phone': '0479-2480570',
        'ei': '9400069504',
        'aei': '9496499235',
        'email': 'eroktkply.exc@kerala.gov.in',
        'address': 'Haripad P.O., Alappuzha - 690514',
      },
      {
        'name': 'Excise Range Office Kayamkulam',
        'phone': '0479-2434858',
        'ei': '9400069505',
        'aei': '9496499238',
        'email': 'erokyklm.exc@kerala.gov.in',
        'address': 'Kayamkulam P.O., Alappuzha - 690502',
      },
      {
        'name': 'Excise Range Office Mavelikkara',
        'phone': '0479-2340270',
        'ei': '9400069502',
        'aei': '9496499224',
        'email': 'eromvka.exc@kerala.gov.in',
        'address': 'Mavelikkara P.O., Alappuzha - 690101',
      },
      {
        'name': 'Excise Range Office Nooranad',
        'phone': '0479-2383400',
        'ei': '9400069503',
        'aei': '9496499229',
        'email': 'eronrnd.exc@kerala.gov.in',
        'address': 'KIP Building, Charamoodu P.O., Alappuzha - 690505',
      },
      {
        'name': 'Excise Range Office Chengannur',
        'phone': '0479-2451818',
        'ei': '9400069501',
        'aei': '9496499212',
        'email': 'erocgnr.exc@kerala.gov.in',
        'address': 'Puthenkavu P.O., Alappuzha - 680123',
      },
      {
        'name': 'K.S.B.C. FL.9 Warehouse, Alappuzha',
        'phone': '0477-2245815',
        'ci': '',
        'email': 'alpyksbc.exc@kerala.gov.in',
        'address': 'Arattuvazhi P.O., Alappuzha - 688007',
      },
      {
        'name': 'United Spirits Limited, Cherthala',
        'phone': '0478-2822634',
        'ci': '',
        'email': 'ciuslctla.exc@kerala.gov.in',
        'address': 'Varanad P.O., Cherthala, Alappuzha - 688543',
      },
      {
        'name': 'United Breweries Limited, Cherthala',
        'phone': '0478-2821636',
        'ei': '',
        'email': 'eiubctla.exc@kerala.gov.in',
        'address': 'Varanad P.O., Cherthala, Alappuzha - 688543',
      },
      {
        'name': 'Kerala State Homoeopathic Co-operative Pharmacy Limited',
        'phone': '0477-2258012',
        'ei': '',
        'email': 'eikshcpalpy.exc@kerala.gov.in',
        'address': 'Pathirapalli P.O., Alappuzha - 688521',
      },
      {
        'name': 'Excise Intelligence & Investigation Bureau',
        'phone': '0477-2251058',
        'ei': '9400069433',
        'email': 'eiibalpy.exc@kerala.gov.in',
        'address': 'Excise Complex, Iron Bridge P.O., Near General Hospital, Alappuzha - 688011',
      },
    ],
    'Kottayam': [
      {
        'name': 'Deputy Excise Commissioner',
        'phone': '0481-2562211',
        'mobile': '9447178057',
        'email': 'decktm.exc@kerala.gov.in',
        'address': 'Excise Division Office, Collectorate P.O., Kottayam - 686002',
      },
      {
        'name': 'Assistant Excise Commissioner E.E. & A.N.S.S.',
        'phone': '0481-2583801',
        'mobile': '9496002865',
        'email': 'aecktm.exc@kerala.gov.in',
        'address': '1st Floor, Excise Complex, Near Old Boat Jetty, Kottayam - 686001',
      },
      {
        'name': 'Excise Enforcement & Anti-Narcotics Special Squad',
        'phone': '0481-2583801',
        'ci': '9400069506',
        'email': 'eeanssktm.exc@kerala.gov.in',
        'address': '1st Floor, Excise Complex, Near Old Boat Jetty, Kottayam - 686001',
      },
      {
        'name': 'Excise Circle Office Kottayam',
        'phone': '0481-2583091',
        'ci': '9400069508',
        'email': 'ecoktm.exc@kerala.gov.in',
        'address': 'Mini Civil Station P.O., Kottayam - 686001',
      },
      {
        'name': 'Excise Circle Office Vaikom',
        'phone': '04829-231592',
        'ci': '9400069512',
        'email': 'ecovkm.exc@kerala.gov.in',
        'address': 'Chalaparamba, Vaikom P.O., Kottayam - 686141',
      },
      {
        'name': 'Excise Circle Office Ponkunnam',
        'phone': '04828-221412',
        'ci': '9400069510',
        'email': 'ecopnkm.exc@kerala.gov.in',
        'address': 'Mini Civil Station Ponkunnam P.O., Kottayam - 686506',
      },
      {
        'name': 'Excise Circle Office Pala',
        'phone': '04822-212235',
        'ci': '9400069511',
        'email': 'ecopala.exc@kerala.gov.in',
        'address': 'Puzhakkara Building, Pala P.O., Kottayam - 686575',
      },
      {
        'name': 'Excise Circle Office Changanassery',
        'phone': '0481-2422741',
        'ci': '9400069509',
        'email': 'ecochry.exc@kerala.gov.in',
        'address': 'Changanassery P.O., Kottayam - 686101',
      },
      {
        'name': 'Excise Range Office Kottayam',
        'phone': '0481-2561833',
        'ei': '9400069513',
        'aei': '9496499259',
        'email': 'eroktm.exc@kerala.gov.in',
        'address': 'Excise Complex, Near Old Boat Jetty, Kottayam - 686001',
      },
      {
        'name': 'Excise Range Office Pampady',
        'phone': '0481-2505011',
        'ei': '9400069515',
        'email': 'eropdy.exc@kerala.gov.in',
        'address': 'Pampady P.O., Kottayam - 686502',
      },
      {
        'name': 'Excise Range Office Ettumanoor',
        'phone': '0481-2533660',
        'ei': '9400069514',
        'email': 'eroetmr.exc@kerala.gov.in',
        'address': 'Ettumanoor P.O., Kottayam - 686631',
      },
      {
        'name': 'Excise Range Office Vaikom',
        'phone': '04829-217440',
        'ei': '9400069521',
        'email': 'erovkm.exc@kerala.gov.in',
        'address': 'Vaikom P.O., Kottayam - 686141',
      },
      {
        'name': 'Excise Range Office Kadathuruthy',
        'phone': '04829-284588',
        'ei': '9400069522',
        'email': 'erokdty.exc@kerala.gov.in',
        'address': 'Kadathuruthy P.O., Kottayam - 686604',
      },
      {
        'name': 'Excise Range Office Kanjirapally',
        'phone': '04828-274677',
        'ei': '9400069518',
        'email': 'erokply.exc@kerala.gov.in',
        'address': 'Mundakkayam P.O., Kottayam - 686513',
      },
      {
        'name': 'Excise Range Office Erumeli',
        'phone': '04828-210000',
        'ei': '9400069517',
        'email': 'eroemly.exc@kerala.gov.in',
        'address': 'Erumeli P.O., Kottayam - 686509',
      },
      {
        'name': 'Excise Range Office Pala',
        'phone': '04822-216729',
        'ei': '9400069516',
        'email': 'eropala.exc@kerala.gov.in',
        'address': 'Pala P.O., Kottayam - 686575',
      },
      {
        'name': 'Excise Range Office Kuruvilangad',
        'phone': '04822-231882',
        'ei': '9400069520',
        'email': 'erokrvngd.exc@kerala.gov.in',
        'address': 'Kozha P.O., Kuruvilangad, Kottayam - 686633',
      },
      {
        'name': 'Excise Range Office Erattupetta',
        'phone': '04822-277999',
        'ei': '9400069519',
        'email': 'eroetpa.exc@kerala.gov.in',
        'address': 'Aruvithura P.O., Kottayam - 686122',
      },
      {
        'name': 'Excise Range Office Changanassery',
        'phone': '0481-2423141',
        'ei': '9400069516',
        'email': 'erochry.exc@kerala.gov.in',
        'address': 'Puzhavath, Changanassery P.O., Kottayam - 686101',
      },
      {
        'name': 'K.S.B.C. FL.9 Warehouse, Kottayam',
        'phone': '0481-2565379',
        'ci': '',
        'email': 'ktmksbc.exc@kerala.gov.in',
        'address': 'SH Mount P.O., Kottayam - 686006',
      },
      {
        'name': 'K.S.B.C. FL.9 Warehouse, Airkunnam',
        'phone': '0481-2545540',
        'ci': '',
        'email': 'ksbcaykm.exc@kerala.gov.in',
        'address': 'Airkunnam P.O., Kottayam - 686564',
      },
      {
        'name': 'Casanova Distillery, Kottayam',
        'phone': '0481-2363141',
        'ei': '',
        'email': 'eicdntm.exc@kerala.gov.in',
        'address': 'Nattaka P.O., Kottayam - 686013',
      },
      {
        'name': 'Excise Intelligence & Investigation Bureau',
        'phone': '0481-2580843',
        'ei': '9400069523',
        'email': 'eiibktm.exc@kerala.gov.in',
        'address': 'Kottayam - 686001',
      },
    ],
    'Idukki': [
      {
        'name': 'Deputy Excise Commissioner',
        'phone': '04862-222493',
        'mobile': '9447178058',
        'email': 'decidk.exc@kerala.gov.in',
        'address': 'Excise Division Office, Excise Complex, Thodupuzha East P.O., Idukki - 685585',
      },
      {
        'name': 'Assistant Excise Commissioner E.E. & A.N.S.S.',
        'phone': '04862-232469',
        'mobile': '9496002866',
        'email': 'aecidk.exc@kerala.gov.in',
        'address': 'Near Armed Reserve Cabin, Kuilimala, Painav P.O., Idukki - 685603',
      },
      {
        'name': 'Excise Enforcement & Anti Narcotics Special Squad',
        'phone': '04862-232469',
        'ci': '9400069532',
        'ei': '9400069533',
        'email': 'eeanssidk.exc@kerala.gov.in',
        'address': 'Near Armed Reserve Cabin, Kuilimala, Painav P.O., Idukki - 685603',
      },
      {
        'name': 'Excise Circle Office Munnar',
        'phone': '04864-278356',
        'ci': '9400069524',
        'ei': '9400069525',
        'email': 'ecomnr.exc@kerala.gov.in',
        'address': '3rd Mile, Pallivasal P.O., Munnar - 685568',
      },
      {
        'name': 'Excise Circle Office Peerumedu',
        'phone': '04869-232018',
        'ci': '9400069526',
        'ei': '9400069527',
        'email': 'ecopermd.exc@kerala.gov.in',
        'address': 'Peerumedu P.O., Idukki - 685531',
      },
      {
        'name': 'Excise Circle Office Udumbanchola',
        'phone': '04868-233247',
        'ci': '9400069528',
        'ei': '9400069529',
        'email': 'ecoudmla.exc@kerala.gov.in',
        'address': 'Nedumkandam P.O., Idukki - 685553',
      },
      {
        'name': 'Excise Circle Office Thodupuzha',
        'phone': '04862-223147',
        'ci': '9400069530',
        'ei': '9400069531',
        'email': 'ecotdpa.exc@kerala.gov.in',
        'address': 'Thodupuzha East P.O., Thodupuzha - 685585',
      },
      {
        'name': 'Excise Circle Office Idukki',
        'phone': '04868-275567',
        'ci': '',
        'email': 'ecoidk.exc@kerala.gov.in',
        'address': 'Thankamani P.O., Thankamani - 685515',
      },
      {
        'name': 'Excise Range Office Devikulam',
        'phone': '04865-230806',
        'ei': '',
        'aei': '9496499353',
        'email': 'erodvklm.exc@kerala.gov.in',
        'address': 'Munnar P.O., Idukki - 685612',
      },
      {
        'name': 'Excise Range Office Marayur',
        'phone': '04865-252526',
        'ei': '9400069537',
        'email': 'eromryr.exc@kerala.gov.in',
        'address': 'Marayur P.O., Idukki - 685620',
      },
      {
        'name': 'Excise Range Office Adimali',
        'phone': '04864-225118',
        'ei': '9400069538',
        'email': 'eroadmly.exc@kerala.gov.in',
        'address': 'Adimali P.O., Idukki - 685561',
      },
      {
        'name': 'Excise Range Office Udumbanchola',
        'phone': '04868-234280',
        'ei': '9400069539',
        'aei': '9496499339',
        'email': 'eroudmla.exc@kerala.gov.in',
        'address': 'Nedumkandam P.O., Idukki - 685553',
      },
      {
        'name': 'Excise Range Office Kattappana',
        'phone': '04868-274465',
        'ei': '9400069540',
        'aei': '9496499343',
        'email': 'eroktpna.exc@kerala.gov.in',
        'address': 'Pallikkavala, Kattappana - 685515',
      },
      {
        'name': 'Excise Range Office Vandiperiyar',
        'phone': '04869-253173',
        'ei': '9400069541',
        'email': 'erovdpr.exc@kerala.gov.in',
        'address': 'Vandiperiyar P.O., Idukki - 685533',
      },
      {
        'name': 'Excise Range Office Thankamani',
        'phone': '04868-275968',
        'ei': '9400069542',
        'aei': '',
        'email': 'erotnkmy.exc@kerala.gov.in',
        'address': 'Thankamani P.O., Idukki - 685515',
      },
      {
        'name': 'Excise Range Office Moolamattom',
        'phone': '04862-233114',
        'ei': '9400069543',
        'aei': '9496499326',
        'email': 'eroidk.exc@kerala.gov.in',
        'address': 'Ilamdesam P.O., Idukki - 685588',
      },
      {
        'name': 'Excise Range Office Thodupuzha',
        'phone': '04862-228544',
        'ei': '9400069544',
        'aei': '9496499321',
        'email': 'erotdpa.exc@kerala.gov.in',
        'address': 'Thodupuzha East P.O., Idukki - 685585',
      },
      {
        'name': 'Excise Range Office Peerumedu',
        'phone': '04869-233028',
        'ei': '9400069545',
        'aei': '9996499331',
        'email': 'eropermd.exc@kerala.gov.in',
        'address': 'Peerumedu P.O., Idukki - 685531',
      },
      {
        'name': 'Excise Check Post Kumily',
        'phone': '04869-223458',
        'ei': '9400069546',
        'email': 'ecpkmly.exc@kerala.gov.in',
        'address': 'Kumily P.O., Idukki - 685509',
      },
      {
        'name': 'Excise Check Post Bodimettu',
        'phone': '04868-220350',
        'ei': '949649930',
        'email': 'ecpbmettu.exc@kerala.gov.in',
        'address': 'Poopara P.O., Bodimettu, Idukki - 685618',
      },
      {
        'name': 'Excise Check Post Chinnar',
        'phone': '',
        'ei': '9400069549',
        'email': 'ecpchinnar.exc@kerala.gov.in',
        'address': 'Marayur P.O., Chinnar, Idukki - 685620',
      },
      {
        'name': 'Excise Check Post Kambammettu',
        'phone': '04868-220350',
        'ei': '9400069548',
        'email': 'ecpcmettu.exc@kerala.gov.in',
        'address': 'Kambammettu P.O., Idukki - 685551',
      },
      {
        'name': 'Narcotics Enforcement Squad Adimali',
        'phone': '04864-225782',
        'ci': '9400069534',
        'ei': '9400069535',
        'email': 'nesadmly.exc@kerala.gov.in',
        'address': 'Adimali P.O., Idukki - 685561',
      },
      {
        'name': 'Janamaithri Excise Squad Devikulam',
        'phone': '04864-223377',
        'ci': '',
        'email': 'jesdvklm.exc@kerala.gov.in',
        'address': 'Adimali P.O., Idukki - 685561',
      },
      {
        'name': 'K.S.B.C. FL.9 Warehouse, Thodupuzha',
        'phone': '04862-223062',
        'ci': '',
        'email': 'idkksbc.exc@kerala.gov.in',
        'address': 'Thodupuzha West P.O., Olamattom, Idukki - 685584',
      },
      {
        'name': 'Excise Intelligence & Investigation Bureau',
        'phone': '04862-232469',
        'ei': '9400069547',
        'email': 'eiibidk.exc@kerala.gov.in',
        'address': 'Near Armed Reserve Cabin, Kuilimala, Painav P.O., Idukki - 685603',
      },
    ],
    'Thrissur': [
      {
        'name': 'Deputy Excise Commissioner',
        'phone': '0487-2361237',
        'mobile': '9447178060',
        'email': 'dectsr.exc@kerala.gov.in',
        'address': 'Excise Division Office, Room No.64, 2nd Floor, Civil Station, Ayyanthol, Thrissur - 680003',
      },
      {
        'name': 'Assistant Excise Commissioner E.E. & A.N.S.S.',
        'phone': '0487-2362002',
        'mobile': '9496002868',
        'email': 'aectsr.exc@kerala.gov.in',
        'address': 'Room No.166, 2nd Floor, Civil Station, Ayyanthol, Thrissur - 680003',
      },
      {
        'name': 'Excise Enforcement & Anti-Narcotics Special Squad',
        'phone': '0487-2362002',
        'ci': '9400069582',
        'ei': '9400069581',
        'email': 'essquadtsr.exc@kerala.gov.in',
        'address': 'Ayyanthol, Room No.166, 2nd Floor, Civil Station, Thrissur - 680003',
      },
      {
        'name': 'Excise Circle Office Thrissur',
        'phone': '0487-2327020',
        'ci': '9400069583',
        'ei': '9400069584',
        'email': 'ecotsr.exc@kerala.gov.in',
        'address': 'Chembukkavu, Thrissur - 680005',
      },
      {
        'name': 'Excise Circle Office Irinjalakuda',
        'phone': '0480-2832800',
        'ci': '9400069589',
        'ei': '9400069590',
        'email': 'ecoijk.exc@kerala.gov.in',
        'address': 'Mini Civil Station, Irinjalakuda - 680125',
      },
      {
        'name': 'Excise Circle Office Kodungallur',
        'phone': '0480-2809390',
        'ci': '9400069591',
        'email': 'ecokdlr.exc@kerala.gov.in',
        'address': 'S.N.G. Building, Sringapuram, Kodungallur, Thrissur - 680664',
      },
      {
        'name': 'Excise Circle Office Vatanapally',
        'phone': '0487-2290005',
        'ci': '9400069587',
        'ei': '9400069588',
        'email': 'ecovtply.exc@kerala.gov.in',
        'address': 'Pookulangara, Engandiyur, Thrissur - 680615',
      },
      {
        'name': 'Excise Circle Office Vadakkancherry',
        'phone': '0488-4232407',
        'ci': '9400069585',
        'ei': '9400069586',
        'email': 'ecowky.exc@kerala.gov.in',
        'address': 'Chalipadam, Vadakkancherry - 680623',
      },
      {
        'name': 'Excise Range Office Thrissur',
        'phone': '0487-2389455',
        'ei': '9400069603',
        'aei': '9496499465',
        'email': 'erotsr.exc@kerala.gov.in',
        'address': 'Poothol, Thrissur - 680001',
      },
      {
        'name': 'Excise Range Office Anthikad',
        'phone': '0487-2631900',
        'ei': '9400069592',
        'email': 'eroakd.exc@kerala.gov.in',
        'address': 'Mini Civil Station, 2nd Floor, Anthikad, Thrissur - 680641',
      },
      {
        'name': 'Excise Range Office Kolazhi',
        'phone': '0487-2204884',
        'ei': '9400069598',
        'aei': '9496499475',
        'email': 'erokzy.exc@kerala.gov.in',
        'address': 'Kolazhi P.O., Thrissur - 680010',
      },
      {
        'name': 'Excise Range Office Cherp',
        'phone': '0487-2348806',
        'ei': '9400069593',
        'email': 'erocherpu.exc@kerala.gov.in',
        'address': 'Cherp P.O., Thrissur',
      },
      {
        'name': 'Excise Range Office Irinjalakuda',
        'phone': '0480-2809390',
        'ei': '9400069596',
        'aei': '9496499478',
        'email': 'eroijk.exc@kerala.gov.in',
        'address': 'Irinjalakuda North P.O., Thrissur - 680125',
      },
      {
        'name': 'Excise Range Office Chalakudy',
        'phone': '0480-2705522',
        'ei': '9400069594',
        'aei': '9496499483',
        'email': 'erockdy.exc@kerala.gov.in',
        'address': 'Chalakudy P.O., Thrissur - 680307',
      },
      {
        'name': 'Excise Range Office Mala',
        'phone': '0480-2895770',
        'ei': '9400069601',
        'email': 'eromla.exc@kerala.gov.in',
        'address': 'Vadama P.O., Thrissur - 680736',
      },
      {
        'name': 'Excise Range Office Kodungallur',
        'phone': '0480-2804630',
        'ei': '9400069597',
        'email': 'erokdlr.exc@kerala.gov.in',
        'address': 'Kodungallur P.O., Thrissur - 680664',
      },
      {
        'name': 'Excise Range Office Vatanapally',
        'phone': '0487-2402990',
        'ei': '9400069604',
        'email': 'erovtply.exc@kerala.gov.in',
        'address': 'Thrithallur P.O., Thrissur - 680619',
      },
      {
        'name': 'Excise Range Office Chavakkad',
        'phone': '0487-2554299',
        'ei': '9400069595',
        'email': 'erocvkd.exc@kerala.gov.in',
        'address': 'Guruvayur P.O., Thrissur - 680101',
      },
      {
        'name': 'Excise Range Office Near Vadakkancherry Police Station',
        'phone': '0488-4231051',
        'ei': '9400069605',
        'aei': '9496499501',
        'email': 'erowky.exc@kerala.gov.in',
        'address': 'Vadakkancherry, Thrissur - 680623',
      },
      {
        'name': 'Excise Range Office Kunnamkulam',
        'phone': '04885-223652',
        'ei': '9400069599',
        'email': 'erokkm.exc@kerala.gov.in',
        'address': 'X/7 Baiji Building, Kecheri P.O., Thrissur - 680510',
      },
      {
        'name': 'Excise Range Office Pazhayannur',
        'phone': '0488-4226087',
        'ei': '9400069602',
        'email': 'eropzr.exc@kerala.gov.in',
        'address': 'Pazhayannur, Thrissur - 680587',
      },
      {
        'name': 'Excise Check Post Vettilappara',
        'phone': '0480-2769011',
        'ei': '9400069606',
        'email': 'ecpvtpa.exc@kerala.gov.in',
        'address': 'Vettilappara P.O., Chalakudy Road, Thrissur - 680721',
      },
      {
        'name': 'K.S.B.C. FL.9 Warehouse, Kuriyachira',
        'phone': '0487-2250524',
        'ci': '',
        'email': 'ksbctsr.exc@kerala.gov.in',
        'address': '1st Block, Nehru Nagar, Pope John Nagar, Kuriyachira P.O., Thrissur - 680006',
      },
      {
        'name': 'K.S.B.C. FL.9 Warehouse, Chalakudy',
        'phone': '0480-2708284',
        'ci': '',
        'email': 'ksbcckdy.exc@kerala.gov.in',
        'address': 'Chalakudy P.O., Thrissur - 680307',
      },
      {
        'name': 'KC Distilleries, Puthukkad',
        'phone': '0480-2751994',
        'ci': '',
        'email': 'cikayceed.exc@kerala.gov.in',
        'address': 'Chengalur P.O., Thrissur',
      },
      {
        'name': 'S.D.F. Industries Limited',
        'phone': '0488-4282705',
        'ci': '',
        'email': 'cisdf.exc@kerala.gov.in',
        'address': 'Pampady, Thiruvilvamala, Thrissur - 680597',
      },
      {
        'name': 'Sevens Distillery Limited',
        'phone': '0487-2370679',
        'ei': '',
        'email': 'eissd.exc@kerala.gov.in',
        'address': 'Mannoothi, Thrissur - 680651',
      },
      {
        'name': 'Malabar Breweries Limited',
        'phone': '0480-2738406',
        'ei': '',
        'email': 'eimbrckdy.exc@kerala.gov.in',
        'address': 'Poolani, Chalakudy, Melur P.O., Thrissur - 680311',
      },
      {
        'name': 'Paulson Distillery',
        'phone': '0480-2704604',
        'ei': '',
        'email': 'eipolsond.exc@kerala.gov.in',
        'address': 'Muringur P.O., Chalakudy, Thrissur - 680309',
      },
      {
        'name': 'Elite Distilleries & Beverages Company, Kiralur',
        'phone': '0487-2212228',
        'ei': '',
        'email': 'eielited.exc@kerala.gov.in',
        'address': 'Mundur P.O., Thrissur - 680541',
      },
      {
        'name': 'Southern Union Pharmaceuticals (Pvt) Ltd.',
        'phone': '0487-2357454',
        'ei': '',
        'email': 'eisuptsr.exc@kerala.gov.in',
        'address': 'Museum Road, Chembukavu, Thrissur - 680014',
      },
      {
        'name': 'Excise Intelligence & Investigation Bureau',
        'phone': '0487-2327144',
        'ei': '9400069607',
        'email': 'eiibtsr.exc@kerala.gov.in',
        'address': 'Chembukkavu, Thrissur - 680005',
      },
      {
        'name': 'State Excise Academy & Research Center (S.E.A.R.C)',
        'address': 'Poothol, Thrissur - 680004',
      },
      {
        'name': 'Joint Excise Commissioner (Principal)',
        'phone': '0487-2388090',
        'mobile': '9400069700',
        'email': 'jecsearc.exc@kerala.gov.in',
        'address': 'State Excise Academy & Research Centre, Poothol, Thrissur - 680004',
      },
      {
        'name': 'Asst. Excise Commissioner (Vice Principal)',
        'phone': '0487-2388090',
        'mobile': '',
        'email': 'jecsearc.exc@kerala.gov.in',
        'address': 'State Excise Academy & Research Centre, Poothol, Thrissur - 680004',
      },
    ],
    'Palakkad': [
      {
        'name': 'Deputy Excise Commissioner',
        'phone': '0491-2505897',
        'mobile': '9447178061',
        'email': 'decplkd.exc@kerala.gov.in',
        'address': 'Excise Division Office, Excise Tower, Durga Nagar, Kenathuparamba, Kunnathurmedu, Palakkad - 678001',
      },
      {
        'name': 'Assistant Excise Commissioner E.E. & A.N.S.S.',
        'phone': '0491-2526277',
        'mobile': '9496002869',
        'email': 'aecplkd.exc@kerala.gov.in',
        'address': 'Excise Tower, Durga Nagar, Kenathuparamba, Kunnathurmedu, Palakkad - 678001',
      },
      {
        'name': 'Excise Enforcement & Anti-Narcotics Special Squad',
        'phone': '0491-2526277',
        'ci': '9400069608',
        'ei': '9400069609',
        'email': 'eeansspkd.exc@kerala.gov.in',
        'address': 'Excise Tower, Durga Nagar, Kenathuparamba, Kunnathurmedu, Palakkad - 678001',
      },
      {
        'name': 'Excise Circle Office Palakkad',
        'phone': '0491-2539260',
        'ci': '9400069430',
        'ei': '9400069432',
        'email': 'ecopkd.exc@kerala.gov.in',
        'address': 'Excise Tower, Durga Nagar, Kenathuparamba, Kunnathurmedu, Palakkad - 678001',
      },
      {
        'name': 'Excise Circle Office Chittoor',
        'phone': '04923-222272',
        'ci': '9400069610',
        'ei': '9400069611',
        'email': 'ecoctr.exc@kerala.gov.in',
        'address': 'Mini Civil Station, Chittoor - 678101',
      },
      {
        'name': 'Excise Circle Office Ottappalam',
        'phone': '0466-2244488',
        'ci': '9400069616',
        'ei': '9400069617',
        'email': 'ecootp.exc@kerala.gov.in',
        'address': 'Near NCC Office, Thottakara P.O., Ottappalam - 679102',
      },
      {
        'name': 'Excise Circle Office Mannarkkad',
        'phone': '04924-225644',
        'ci': '9400069614',
        'ei': '9400069615',
        'email': 'ecomkd.exc@kerala.gov.in',
        'address': 'V.K. Lodge, Kothipady, Mannarkkad, Palakkad - 678582',
      },
      {
        'name': 'Excise Circle Office Alathur',
        'phone': '04922-222474',
        'ci': '9400069612',
        'ei': '9400069613',
        'email': 'ecoalr.exc@kerala.gov.in',
        'address': 'Mini Civil Station Building, Swathi Junction, Alathur - 678541',
      },
      {
        'name': 'Excise Range Office Nemmara',
        'phone': '04923-241700',
        'ei': '9400069620',
        'email': 'eronmra.exc@kerala.gov.in',
        'address': 'Nemmara, Palakkad - 678508',
      },
      {
        'name': 'Excise Range Office Thritala',
        'phone': '0466-2313677',
        'ei': '9400069630',
        'aei': '9496499582',
        'email': 'erotla.exc@kerala.gov.in',
        'address': 'Nangattiri P.O., Pattambi - 679303',
      },
      {
        'name': 'Excise Range Office Alathur',
        'phone': '04922-226020',
        'ei': '9400069622',
        'email': 'eroalr.exc@kerala.gov.in',
        'address': 'Mini Civil Station, 5th Floor, Alathur - 678541',
      },
      {
        'name': 'Excise Range Office Kollangode',
        'phone': '04923-263886',
        'ei': '9400069621',
        'aei': '9496499566',
        'email': 'eroklgd.exc@kerala.gov.in',
        'address': 'Building No. XVll/380, Aruvannoorparamba, Kollangode P.O., Palakkad - 678506',
      },
      {
        'name': 'Excise Range Office Cherpulassery',
        'phone': '0466-2380844',
        'ei': '9400069629',
        'aei': '9496499578',
        'email': 'erocply.exc@kerala.gov.in',
        'address': 'Cherpulassery, Palakkad - 679502',
      },
      {
        'name': 'Excise Range Office Palakkad',
        'phone': '0491-2570341',
        'ei': '9400069618',
        'aei': '9496499535',
        'email': 'eropkd.exc@kerala.gov.in',
        'address': 'Excise Tower, Durga Nagar, Kenathuparamba, Kunnathurmedu, Palakkad - 678001',
      },
      {
        'name': 'Excise Range Office Pattambi',
        'phone': '0466-2214050',
        'ei': '9400069628',
        'email': 'eroptb.exc@kerala.gov.in',
        'address': 'Mini Civil Station, Pattambi - 679303',
      },
      {
        'name': 'Excise Range Office Chittoor',
        'phone': '04923-221849',
        'ei': '9400069619',
        'aei': '9496499542',
        'email': 'eroctr.exc@kerala.gov.in',
        'address': 'Kacherimedu, Chittoor - 678101',
      },
      {
        'name': 'Excise Range Office Parali',
        'phone': '0491-2858700',
        'ei': '9400069627',
        'aei': '9496499539',
        'email': 'eroprli.exc@kerala.gov.in',
        'address': 'Parali Check Post, P.K.V. Tower, Parali - 678612',
      },
      {
        'name': 'Excise Range Office Mannarkkad',
        'phone': '04924-226768',
        'ei': '9400069624',
        'email': 'eromkd.exc@kerala.gov.in',
        'address': 'Mini Civil Station, Mannarkkad - 678582',
      },
      {
        'name': 'Excise Range Office Agali',
        'phone': '04924-254163',
        'ei': '9400069625',
        'aei': '9496499551',
        'email': 'eroagali.exc@kerala.gov.in',
        'address': 'Goolikkadavu, Agali - 678581',
      },
      {
        'name': 'Excise Range Office Kuzhalmannam',
        'phone': '04922-226020',
        'ei': '9400069623',
        'aei': '9496499561',
        'email': 'erokzlm.exc@kerala.gov.in',
        'address': 'Kuzhalmannam, Palakkad - 678702',
      },
      {
        'name': 'Excise Range Office Ottappalam',
        'phone': '0466-2248799',
        'ei': '9400069626',
        'aei': '9496499574',
        'email': 'eroopt.exc@kerala.gov.in',
        'address': 'Manissery P.O., Ottappalam - 679104',
      },
      {
        'name': 'Excise Check Post Walayar',
        'phone': '0491-2862191',
        'ci': '9400069631',
        'ei': '9400069632',
        'email': 'wlrecp.exc@kerala.gov.in',
        'address': 'Puthussery Panchayat, Walayar P.O., Palakkad - 678624',
      },
      {
        'name': 'Excise Check Post Velanthavalam',
        'phone': '04923-235820',
        'ei': '9400069637',
        'email': '',
        'address': '4/691, Vadakarapathi, Chunnambukalthode, Velanthavalam P.O. - 678557',
      },
      {
        'name': 'Excise Check Post Govindapuram',
        'phone': '04923-275950',
        'ei': '9400069634',
        'email': '',
        'address': 'Govindapuram P.O., Palakkad - 678507',
      },
      {
        'name': 'Excise Check Post Chemmanampathi',
        'phone': '04923-277441',
        'ei': '9400069630',
        'email': '',
        'address': '8/254, Govindapuram P.O., Anakattimedu, Palakkad - 678507',
      },
      {
        'name': 'Excise Check Post Anakatti',
        'phone': '04924-254651',
        'ei': '9496499601',
        'email': '',
        'address': 'Mattathukad P.O., Sholayur, Mannarkkad - 678581',
      },
      {
        'name': 'Excise Check Post Nadupuni',
        'phone': '04923-236110',
        'ei': '9400069638',
        'email': '',
        'address': 'Kaikatty, Nadupuni P.O., Palakkad - 678555',
      },
      {
        'name': 'Excise Check Post Govindapuram',
        'phone': '04923-236840',
        'ei': '9400069635',
        'email': '',
        'address': '7/442, Vannamada P.O., Palakkad - 678555',
      },
      {
        'name': 'Excise Check Post Kuppandakaundannur',
        'phone': '04923-204024',
        'ei': '9496499614',
        'email': '',
        'address': '7/23, Ozhalapathy P.O., Palakkad - 678556',
      },
      {
        'name': 'Excise Check Post Meenakshipuram',
        'phone': '04923-234275',
        'ei': '9400069636',
        'email': '',
        'address': '10/395, Mulakkada, Meenakshipuram P.O., Palakkad - 678533',
      },
      {
        'name': 'Janamaithri Excise Squad Attappadi',
        'phone': '04924-254079',
        'ci': '9496499588',
        'ei': '9496499589',
        'email': 'jmesattapadi.exc@kerala.gov.in',
        'address': 'Kottathara P.O., Attappadi, Palakkad - 678581',
      },
      {
        'name': 'K.S.B.C. FL.9 Warehouse, Palakkad',
        'phone': '0491-2538094',
        'ci': '',
        'email': 'pkdksbc.exc@kerala.gov.in',
        'address': 'English Church Road, Palakkad - 678001',
      },
      {
        'name': 'K.S.B.C. FL.9 Warehouse, Menonpara',
        'phone': '0491-2538094',
        'ci': '',
        'email': '',
        'address': 'Menonpara P.O., Palakkad - 678556',
      },
      {
        'name': 'Kerala Alcoholic Products Limited, Meenakshipuram',
        'phone': '04923-234257',
        'ei': '',
        'email': 'eikaplpkd.exc@kerala.gov.in',
        'address': 'Gopalapuram Road, Moolathara Village, Meenakshipuram, Palakkad - 678533',
      },
      {
        'name': 'Amruth Distillery Limited',
        'phone': '04912-567593',
        'ei': '',
        'email': 'eiadlpkd.exc@kerala.gov.in',
        'address': 'Chullimada, Chullimada, Pambampalam P.O., Palakkad - 678621',
      },
      {
        'name': 'United Spirits Limited',
        'phone': '04912-567180',
        'ei': '',
        'email': 'eiuslpkd.exc@kerala.gov.in',
        'address': 'Kanchikode, Palakkad - 678621',
      },
      {
        'name': 'MP Distillery Limited',
        'phone': '04912-568492',
        'ei': '',
        'email': 'eimpdpkd.exc@kerala.gov.in',
        'address': 'New Industrial Development Area, Kanchikode, Palakkad - 678621',
      },
      {
        'name': 'Imperial Spirits Limited',
        'phone': '04923-275050',
        'ei': '',
        'email': 'impdispkd.exc@kerala.gov.in',
        'address': 'Govindapuram, Palakkad - 678507',
      },
      {
        'name': 'United Breweries Limited',
        'phone': '0491-2566161',
        'ci': '',
        'email': 'eiublpkd.exc@kerala.gov.in',
        'address': 'Kanchikode, Palakkad - 678623',
      },
      {
        'name': 'Excise Intelligence & Investigation Bureau',
        'phone': '0491-2534070',
        'ei': '9400069633',
        'email': 'eiibplkd.exc@kerala.gov.in',
        'address': 'Excise Tower, Durga Nagar, Kenathuparamba, Kunnathurmedu, Palakkad - 678001',
      },
    ],
  

  'S.E.A.R.C.': [
   
    {
      'name': 'Joint Excise Commissioner (Principal)',
      'phone': '0487-2388090',
      'mobile': '9400069700',
      'email': 'jecsearc.exc@kerala.gov.in',
      'address': 'State Excise Academy & Research Centre, Poothol, Thrissur - 680004',
    },
    {
      'name': 'Asst. Excise Commissioner (Vice Principal)',
      'phone': '0487-2388090',
      'mobile': '',
      'email': 'jecsearc.exc@kerala.gov.in',
      'address': 'State Excise Academy & Research Centre, Poothol, Thrissur - 680004',
    },
  ],
  // ... other districts ...
};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Row(
          children: [
            Image.asset(
              'assets/brightpath_logo.png',
              height: 32,
              errorBuilder: (context, error, stackTrace) => const SizedBox(width: 32),
            ),
            const SizedBox(width: 12),
            const Text(
              'BrightPath',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[50]!,
              Colors.white,
              Colors.blue[50]!,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Motto Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.security, size: 48, color: Colors.blue[700]),
                        const SizedBox(height: 16),
                        Text(
                          'Motto',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Jagarog, Baligrah - Prudent in actions and dedicated to the betterment of the country',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Region Selection
                  _buildSelectionContainer(
                    title: 'Select Region',
                    icon: Icons.location_city,
                    child: _buildStyledDropdown(
                      value: selectedRegion,
                      items: regions.keys.toList(),
                      hint: 'Choose a region',
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedRegion = newValue;
                          selectedDistrict = null;
                        });
                      },
                    ),
                  ),
                  if (selectedRegion != null) ...[
                    const SizedBox(height: 16),
                    // District Selection
                    _buildSelectionContainer(
                      title: 'Select District',
                      icon: Icons.location_on,
                      child: _buildStyledDropdown(
                        value: selectedDistrict,
                        items: regions[selectedRegion]!,
                        hint: 'Choose a district',
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedDistrict = newValue;
                          });
                        },
                      ),
                    ),
                  ],
                  if (selectedDistrict != null && contactDetails[selectedDistrict] != null) ...[
                    const SizedBox(height: 24),
                    // Contact Cards
                    ...contactDetails[selectedDistrict]!.map((officer) => _buildContactCard(officer)),
                  ],
                  const SizedBox(height: 24),
                  // Help Desk Card
                  _buildHelpDeskCard(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: MouseRegion(
                onHover: (event) {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final position = box.globalToLocal(event.position);
                  final width = box.size.width;
                  final index = (position.dx / (width / 5)).floor();
                  setState(() {
                    _hoveredIndex = index;
                  });
                },
                onExit: (event) {
                  setState(() {
                    _hoveredIndex = null;
                  });
                },
                child: BottomNavigationBar(
                  items: _buildNavItems(),
                  currentIndex: _selectedIndex,
                  selectedItemColor: Colors.blue[700],
                  unselectedItemColor: Colors.grey[400],
                  showUnselectedLabels: true,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedFontSize: 12,
                  unselectedFontSize: 12,
                  onTap: _onItemTapped,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionContainer({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue[700], size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildStyledDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(color: Colors.grey[600])),
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: Colors.blue[600]),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildContactCard(Map<String, String> officer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  officer['name'] ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _buildContactInfo(
                  icon: Icons.phone,
                  label: 'Phone',
                  value: officer['phone'],
                  onTap: () => _makePhoneCall(officer['phone']),
                ),
                if (officer['mobile'] != null && officer['mobile']!.isNotEmpty)
                  _buildContactInfo(
                    icon: Icons.phone_android,
                    label: 'Mobile',
                    value: officer['mobile'],
                    onTap: () => _makePhoneCall(officer['mobile']),
                  ),
                _buildContactInfo(
                  icon: Icons.email,
                  label: 'Email',
                  value: officer['email'],
                  onTap: () => _sendEmail(officer['email']),
                ),
                _buildContactInfo(
                  icon: Icons.location_on,
                  label: 'Address',
                  value: officer['address'],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo({
    required IconData icon,
    required String label,
    String? value,
    VoidCallback? onTap,
  }) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Colors.blue[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$value',
                style: TextStyle(
                  color: onTap != null ? Colors.blue[700] : Colors.grey[700],
                  decoration: onTap != null ? TextDecoration.underline : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpDeskCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Help Desk',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 12),
          _buildContactInfo(
            icon: Icons.phone,
            label: 'Phone',
            value: '0471-2322825',
            onTap: () => _makePhoneCall('0471-2322825'),
          ),
          _buildContactInfo(
            icon: Icons.phone_android,
            label: 'Mobile',
            value: '9447178000',
            onTap: () => _makePhoneCall('9447178000'),
          ),
          _buildContactInfo(
            icon: Icons.email,
            label: 'Email',
            value: 'cru.excise@kerala.gov.in',
            onTap: () => _sendEmail('cru.excise@kerala.gov.in'),
          ),
          _buildContactInfo(
            icon: Icons.print,
            label: 'Fax',
            value: '0471-2332073',
          ),
          _buildContactInfo(
            icon: Icons.computer,
            label: 'I.T. Cell',
            value: '0471-2335568',
          ),
        ],
      ),
    );
  }

  List<BottomNavigationBarItem> _buildNavItems() {
    final items = [
      NavItem(Icons.home_rounded, Icons.home_outlined, 'Home'),
      NavItem(Icons.group_rounded, Icons.group_outlined, 'Community'),
      NavItem(Icons.add_circle_rounded, Icons.add_circle_outlined, 'Report'),
      NavItem(Icons.notifications_rounded, Icons.notifications_outlined, 'Alerts'),
      NavItem(Icons.medical_services_rounded, Icons.medical_services_outlined, 'Prevention'),
      NavItem(Icons.person_rounded, Icons.person_outlined, 'Profile'),
    ];

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isHovered = _hoveredIndex == index;
      final isSelected = _selectedIndex == index;

      return BottomNavigationBarItem(
        icon: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(isHovered || isSelected ? 8.0 : 6.0),
          decoration: BoxDecoration(
            color: isSelected 
                ? Colors.blue[700] 
                : isHovered 
                    ? Colors.blue[50] 
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected || isHovered
                ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            isSelected || isHovered ? item.selectedIcon : item.icon,
            size: isHovered || isSelected ? 28 : 24,
            color: isSelected 
                ? Colors.white 
                : isHovered 
                    ? Colors.blue[700] 
                    : Colors.grey[400],
          ),
        ),
        label: item.label,
      );
    }).toList();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Add navigation logic here
  }

  void _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );
      await launch(launchUri.toString());
    }
  }

  void _sendEmail(String? email) async {
    if (email != null && email.isNotEmpty) {
      final Uri launchUri = Uri(
        scheme: 'mailto',
        path: email,
      );
      await launch(launchUri.toString());
    }
  }
}

class NavItem {
  final IconData selectedIcon;
  final IconData icon;
  final String label;

  NavItem(this.selectedIcon, this.icon, this.label);
}