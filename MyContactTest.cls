@isTest
public class MyContactTest {   

     @isTest   
     public static void testMyController() {
         /* инициализируем настройки */
        insert new PriorityContactLevel__c(Name='Primary', Priority__c='High');
        insert new PriorityContactLevel__c(Name='Secondary', Priority__c='Medium');
        insert new PriorityContactLevel__c(Name='Tertiary', Priority__c='Low');   
        insert new PageSize__c(Size__c=10);   
          
        /* тестирование метода getPageSize */
        MyContactController controller1 = new MyContactController();

        controller1.setPageSize( 8 );
        controller1.sortExpression = 'Email';
        controller1.setSortDirection('DESC');

        controller1.setPageNumber(13);
        controller1.setTotalPageNumber(2);

        System.assertEquals(8, controller1.getPageSize() );
        System.assertEquals('DESC', controller1.getSortDirection() );
        System.assertEquals(13, controller1.getPageNumber() );
        System.assertEquals(2, controller1.getTotalPageNumber() );
        System.assertEquals(true, controller1.getNextButtonDisabled() );
        System.assertEquals('Email', controller1.sortExpression );

        controller1.setPageNumber(1);
        System.assertEquals(true, controller1.getPreviousButtonEnabled() );

        controller1.setPageNumber(3);
        controller1.nextBtnClick();
        System.assertEquals(4, controller1.getPageNumber() );
        
        controller1.setPageNumber(3);
        controller1.previousBtnClick();
        System.assertEquals(2, controller1.getPageNumber() );
        
        MyContactController controller4 = new MyContactController();
        controller1.ViewData( );
        System.assert(controller1.getContacts()!=null);
        
        MyContactController controller5 = new MyContactController();
        controller5.BindData(1);
        System.assert(controller1.getContacts()!=null);

        /* тест функции поиска */
        MyContactController controller13 = new MyContactController();
        controller13.setsearchTextName('Tatsiana');
        controller13.search();
        System.assert(true ,controller13.getContacts() == null );
        System.assert(true ,controller13.getNextButtonDisabled());

        Contact cContact = new Contact(FirstName = 'FistName Test Search', LastName='Lastname Test Search');
        MyContactController controller= new MyContactController();
        controller.prod = cContact ;
        controller.save();
        controller.setsearchTextName('Lastname Test Search');
        controller.search();
        System.assert(true ,controller.getContacts() != null );
        controller.sortExpression = '';
        System.assertEquals('ASC', controller.getSortDirection() );        
       
     }
     
     @isTest   
     public static void testContactMethods() {
         /* инициализируем настройки */
        insert new PriorityContactLevel__c(Name='Primary', Priority__c='High');
        insert new PriorityContactLevel__c(Name='Secondary', Priority__c='Medium');
        insert new PriorityContactLevel__c(Name='Tertiary', Priority__c='Low');   
        insert new PageSize__c(Size__c=10);   
          
        /* создадим тестовый Account */
        Account cAccount = new Account(Name = 'Test Account', OwnerId = UserInfo.getUserId());
        insert cAccount;
                
        Contact cContact = new Contact(FirstName = 'FistName Test', LastName='Lastname Test', AccountId = cAccount.Id);
        MyContactController controller= new MyContactController();
        controller.prod = cContact ;
        controller.save();
 
        /* тестирование метода del */
        MyContactController controllerDel = new MyContactController();
        Contact cContact2 = new Contact(FirstName = 'FistName Test Del', LastName='Lastname Test Del',Contact_Level__c ='Tertiary');
        controllerDel.prod = cContact2 ;
        controllerDel.save();
        /* проверим что Case создан */
        List<AggregateResult> iCaseAdd = [SELECT count(Id) countCase FROM Case WHERE ContactId=:controllerDel.prod.Id];
        System.assertEquals(1, iCaseAdd[0].get('countCase') );
        /* проверим что для поля  Priority выбрано правильное значение */
        Case casePriority = [SELECT Priority FROM Case WHERE ContactId=:controllerDel.prod.Id];
        System.assertEquals('Low', casePriority.Priority );


        Contact contdata2 = [SELECT Id, LastName  FROM Contact WHERE LastName='Lastname Test Del'];
        system.debug('deletemytest '+contdata2);
        controllerDel.ATMID = contdata2.Id;
        controllerDel.Del();
        List<AggregateResult> i = [SELECT count(Id) myCount FROM Contact WHERE LastName='Lastname Test Del'];
        System.assertEquals(0, i[0].get('myCount') );
        /* проверим что Case тоже удален */
        List<AggregateResult> iCase = [SELECT count(Id) countCase FROM Case WHERE ContactId=:contdata2.Id];
        System.assertEquals(0, iCase[0].get('countCase') );

     }
}