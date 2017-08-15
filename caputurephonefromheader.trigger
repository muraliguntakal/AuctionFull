trigger caputurephonefromheader on Case (before insert , before update) {
    string s1;
    string s2 = 'From:';
    string s3;
    string s4;
   for(case c : trigger.new)
   {
   if(c.Email_Header__c != null && c.Email_Header__c != '')
   {
        s1 = c.Email_Header__c;
        system.debug('***********print entry string****'+s1);
        Integer result = s1.lastIndexOf(s2);
        // System.assertEquals(result, 1);
        system.debug('***********print result****'+result);
        s3 = s1.substring(result+5,result+16);
        //s4= '-'+s3;
        c.Emailheader_Phone__c = s3.substring(0,4)+'-'+s3.substring(4,7)+'-'+s3.substring(7,11);
    }
    }
}