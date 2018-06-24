public class MyContactController {

    public MyContactController() {
        prod=new Contact ();
        pageNumber = 0;
        totalPageNumber = 0;
        pageSize = Integer.valueOf(PageSize__c.getInstance().Size__c);
        ViewData();
    }

    public Contact prod {get; set;}
    public String ATMID {get;set;}
    public string searchTextName {get;set;}
    private List<Contact > contacts;
    private List<Contact > pagecontacts;
    private String sortDirection = 'ASC';
    private String sortExp = 'Name';
    private Integer pageNumber;
    private Integer pageSize;
    private Integer totalPageNumber;
  
  
  public Integer getPageNumber()
  {
    return pageNumber;
  }

  public void setPageNumber( Integer pageData)
  {
    pageNumber = pageData;
  }
   
  public void setsearchTextName( String searchTextNameData ){
    searchTextName  = searchTextNameData; 
  }

  public String sortExpression 
  {
    get {   return sortExp;  } 
    set {
    if (value == sortExp)
      sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
    else
      sortDirection = 'ASC';
      sortExp = value;
    }
  }  

  public String getSortDirection()
  {
    if (sortExpression == null || sortExpression == '')
      return 'ASC';
    else
      return sortDirection;
  }

  public void setSortDirection(String value)    
  {
    sortDirection = value;
  }
  
  public List<Contact> getcontacts()
  {
    return pagecontacts;
  }
  
  public void setPageSize(Integer  setdata)
  {
    pageSize =setdata ;
  }
  public Integer getPageSize()
  {
    return pageSize;
  }
  public Boolean getPreviousButtonEnabled()
  {
    return !(pageNumber > 1);
  }
  public Boolean getNextButtonDisabled()
  {
    if (contacts == null)
      return true;
    else
      return ((pageNumber * pageSize) >= contacts.size());
  }
  public void setTotalPageNumber(Integer totalData){
      totalPageNumber = totalData;
  }
  public Integer getTotalPageNumber()
  {
    if (totalPageNumber == 0 && contacts !=null)
    {
      totalPageNumber = contacts.size() / pageSize;
      Integer mod = contacts.size() - (totalPageNumber * pageSize);
      if (mod > 0)
        totalPageNumber++;
    }
    return totalPageNumber;
  }    
    public PageReference ViewData()
  {
    contacts = null;
    totalPageNumber = 0;
    BindData(1);
    return null;
  }
  public void BindData(Integer newPageIndex)
  {
    try
    {
      string sortFullExp = sortExpression  + ' ' + sortDirection;
      String Querycontacts = 'SELECT Id, Name,Email,Contact_Level__c, AccountId, Account.Name , Owner.Id, Owner.Name,CreatedBy.Id, CreatedBy.Name, CreatedDate ' +
            'FROM Contact ' ;
      if (searchTextName!= null && searchTextName!= ''  ) {
        Querycontacts += ' WHERE LastName LIKE \'%' + String.escapeSingleQuotes( searchTextName) + '%\' OR FirstName LIKE \'%' + String.escapeSingleQuotes( searchTextName) + '%\' ';
      }
       
      Querycontacts += ' ORDER BY ' + sortFullExp;
      contacts = Database.query( Querycontacts );
      
      pagecontacts = new List<Contact >{};
      Transient Integer counter = 0;
      Transient Integer min = 0;
      Transient Integer max = 0;    
      if (newPageIndex > pageNumber)
      {
        min = pageNumber * pageSize;
        max = newPageIndex * pageSize;
      } 
      else 
      {
        max = newPageIndex * pageSize;    
        min = max - pageSize;
      }
      for(Contact  a : contacts)    
      {
        counter++;
        if (counter > min && counter <= max)
          pagecontacts.add(a);
      }
      pageNumber = newPageIndex;
      
      if (pagecontacts == null || pagecontacts.size() <= 0)    
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Data not available for this view.'));
    }
    catch(Exception ex)    
    {
      ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getMessage()));
    }
  }    
  public PageReference nextBtnClick() 
  {
    BindData(pageNumber + 1);
    return null;    
  }
  public PageReference previousBtnClick() 
  {    
    BindData(pageNumber - 1);
    return null;
  }
  
  public PageReference search() 
  {
     totalPageNumber = 0;
     BindData(1);
     return null;
  }
  
  /*Сохранение нового товара*/
  public pagereference Save()
  {
    try{
      
      insert prod;
      ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.CONFIRM,'Record Created Successfully.Thank you!'));
      PageReference contPage = new PageReference('/apex/My_Contract_View');
      contPage.setRedirect(true);
      return contPage;
    } catch(System.DmlException e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
      return null;
    }
  }
   
  /*Удаление товара*/
  public pagereference Del()
  {
    Savepoint sp = Database.setSavepoint();
    try{
    
      Case oCase = [SELECT Id FROM Case WHERE ContactId=:ATMId];
      delete oCase;
      
      Contact atm1 = new Contact(id=ATMId);
      delete atm1;
      ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.CONFIRM,'Record Delete Successfully.'));
      PageReference contPage = new PageReference('/apex/My_Contract_View');
      contPage.setRedirect(true);
      return contPage;
    }catch(System.DmlException e) {
      Database.rollback(sp);
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
      return null;
    }
      
  }
}