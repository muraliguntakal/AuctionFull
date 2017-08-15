public class CampforceFormat {

        public static string formatPhone (String sfPhone) {
        
        sfPhone = sfPhone.replaceAll('\\(','');
        sfPhone = sfPhone.replaceAll('\\)','');
        sfPhone = sfPhone.replaceAll(' ','');
        sfPhone = sfPhone.replaceAll('\\-','');
        
          sfPhone = formatphonenum(sfPhone);
          return sfPhone;  
    }
   
    static String formatphonenum (String s) {
        s = s.substring(0, 3) + '-' + s.substring(3, 6) + '-' + s.substring(6);
        return s;
    }
}