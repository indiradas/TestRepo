/*=========================================================================================================
* Date         : 08/08/2016
* Developer    : Sandeep S
* Purpose      : Extension for Customized Proposed Product VisualForce page.
*
*=========================================================================================================
*                                 Update History
*                                 ---------------
* Date       | Developer  | Tag  |      Description
*============+============+================================================================================
* 08/08/2016 | Sandeep S  |      | Initial Version                                         
* 12/08/2016 | Asif K     | T01  | Added braces for if-else statement & catch block for handling DMLException
* 12/12/2016 |Indira Das    | T02  | updated class to handled blanl pp id/brfid/planid
*============+============+======+=========================================================================
*/
public with sharing class AIA_ProposedProductExtension {
    
    public Boolean isMedical{get;set;}
    public Boolean isDental{get;set;}
    public Boolean isVision{get;set;}
    public Boolean isDrug{get;set;}
    public Boolean isPrivateExchange{get;set;}
    public Proposed_Products__c ppc{get;set;}
    public ApexPages.StandardController ctler{get; set;}
    public boolean hasBnefitSummary {get;set;}    
    String brfId=Apexpages.currentPage().getParameters().get('brfId');
    
    
    public AIA_ProposedProductExtension(ApexPages.StandardController controller){
        String pid=ApexPages.currentPage().getParameters().get('id');        
        string brf=ApexPages.currentPage().getParameters().get('brfid');
        ctler=controller;
        hasBnefitSummary = false;
        System.debug('pid------->'+pid);
        String recordType='';
        if(String.isBlank(pid)){
            String planId=ApexPages.currentPage().getParameters().get('planid');
            String brfId=ApexPages.currentPage().getParameters().get('brfId');
            System.debug('Inside Extension--->'+planId);
            ppc=(Proposed_Products__c)controller.getRecord();
            Schema.DescribeSObjectResult R = Proposed_Products__c.SObjectType.getDescribe();
            List<Schema.RecordTypeInfo> rtList = R.getRecordTypeInfos();
            String recordTypeId=''; 
             //T02 - Start
         
                    if(!String.isBlank(brfId)){
               ppc.Benefit_Request_Form__c=Id.valueOf(brfId);
               String queryString1=QueryBase2.getSobjectAllFieldsSOQL( 'Benfit_Request_Form__c',  'id=:brfId');
                List<Benfit_Request_Form__c> brfList=database.query(queryString1);
                if(brfList.size()>0){
                Benfit_Request_Form__c b=brfList.get(0);
                
                ppc.Funding_Arrangement__c = b.Funding_Arrangements__c ;  
             
            }     
 
            if(!String.isBlank(planId)){
          //T02 - End
                ppc.Plan_Name__c=Id.valueOf(planId);    
                String queryString=QueryBase2.getSobjectAllFieldsSOQL( 'AIA_Plan__c',  'id=:planId');
                List<AIA_Plan__c> planList=database.query(queryString);
                if(planList.size()>0){
                    AIA_Plan__c p=planList.get(0);
                    hasBnefitSummary = p.Has_Benefit_Summary__c;
                    //T01 - Start
                    if(String.valueOf(p.Product_Category__c)!='Pharmacy') {
                        recordType=String.valueOf(p.Product_Category__c);
                    }
                    else { 
                        recordType='Drug';   
                    }
                    //T01 - End
                    if(recordType=='Medical'){
                 //   ppc.funding_arrangement_c = b.funding_arrangements__c;
                        ppc.CDH__c=p.CDH__c;
                        ppc.CDH_Fund_Type__c=p.CDH_Fund_Type__c;
                        ppc.CDH_Type__c=p.CDH_Type__c;
                        ppc.Product_Line__c=p.Product_Line__c;
                        ppc.Deductible__c=p.DeductibleAccumulatorMethod__c;
                        ppc.Product_Category__c=p.Product_Category__c;
                        ppc.Product_Name__c=p.Plan_Name__c;
                        ppc.Product_Option__c=p.Option__c;
                        ppc.Integrated_Non_Integrated__c=p.Integrated_DedIndicator__c;
                        ppc.RX_OOP_Max_Integration__c=p.Integrated_OOP_Indicator__c;
                        ppc.Out_of_Pocket_Max__c=p.OOPAccumulatorMethod__c;
                        ppc.Network_Levels__c=p.Network_Levels__c;
                    }
                    if(recordType=='Drug'){
                        ppc.Product_Name__c=p.Plan_Name__c;
                        //ppc.Drug_Product_Options__c=p.Option__c;
                        ppc.Deductible__c=p.DeductibleAccumulatorMethod__c;
                        ppc.Product_Category__c=p.Product_Category__c;
                        ppc.Integrated_Non_Integrated__c=p.Integrated_DedIndicator__c;
                        ppc.RX_OOP_Max_Integration__c=p.Integrated_OOP_Indicator__c;
                        //ppc.Out_of_Pocket_Max__c=p.OOPAccumulatorMethod__c;
                        ppc.Tiers1__c=String.valueof(p.TierCount__c);
                        ppc.Integrated_Deductibles_and_OOPs__c=p.Integrated_DedIndicator__c +' & '+ p.Integrated_OOP_Indicator__c;
                        ppc.Network__c=p.network__c;
                        ppc.Prior_Authorization__c=p.PriorAuth__c=='Yes'?TRUE:FALSE;
                        ppc.Preventive_Drugs_Affordable_Care_Act__c=p.RetDispnsMaintDaysSupp__c;
                        ppc.Generic_Drugs_Tier_1__c=p.RetDispnsMaintDaysSupp__c;
                        ppc.Preferred_Brand_Drugs_Tier_2__c=p.RetDispnsMaintDaysSupp__c;
                        ppc.Self_administered_Injectable_Tier_4__c=p.RetDispnsMaintDaysSupp__c;
                        ppc.Maintenance_Drugs__c=p.RetDispnsMaintDaysSupp__c;
                        ppc.Generic_Step_Therapy__c=p.GenStepTherapy__c;
                        ppc.Generic_Dispensing__c=p.GenDispsng__c;
                    }
                    if(recordType=='Vision'){
                        ppc.Vision_Product_Name__c=p.Plan_Name__c;
                        ppc.Vision_Product_Options__c=p.Option__c;
                    }
                   
                }
                
                
            }
            }
            for(Schema.RecordTypeInfo rtInfo:rtList){
                if(rtInfo.getName()==recordType){
                    recordTypeId=rtInfo.getRecordTypeId();
                    ppc.recordtypeid=recordTypeId;
                    
                }
            }
            enableRecordType(recordType);
        }else{
               //T02 - Start
             ppc =[select id,recordtype.name from Proposed_Products__c where id=:pid];
            recordType=ppc.recordtype.name;
            enableRecordType(recordType);
               //T02 - End
        }
    }
    
    public void enableRecordType(String recordType){
        System.debug('RecordType is--->'+recordType);
        if(recordType=='Medical'){
            isMedical=true;
        }else if(recordType=='Drug'){
            isDrug=true;
        }else if(recordType=='Dental'){
            isDental=true;  
        }else if(recordType=='Vision'){
            isVision=true; 
        }else if(recordType=='CareFirst Private Exchange'){
            isPrivateExchange=true;  
        }
    }
    
    public PageReference cancel(){
        String planId=Apexpages.currentPage().getParameters().get('planId');
        String brfId=Apexpages.currentPage().getParameters().get('brfId');
        String pppid=Apexpages.currentPage().getParameters().get('id');
        PageReference pg=null; 
        System.debug('PlanId---->'+planId);
        System.debug('brfId---->'+brfId);
        if(String.isNotBlank(planId) && String.isNotBlank(brfId)){
            System.debug('inside if condition');
            pg=new PageReference('/apex/AIA_ProductSearchFiltering');
            pg.getParameters().put('brfId',brfId);
        }else if(String.isNotBlank(pppid)){
            pg=new PageReference('/'+pppid);
        }
        return pg;
    }
    public PageReference saveandGetBenefits(){
        PageReference saveMethodPgRef = save();
        system.debug('ppc'+ppc);
       // system.debug('ppc'+ppc.id);
        if(String.isNotBlank(ppc.id))
        {
            PageReference pgRef = new pageReference('/apex/AIA_ProposedProd_Summary?scontrolCaching=1&id='+ppc.id);
            pgRef.setRedirect(true);
            return pgRef;
        }
        else {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Proposed Product Record could not be added. Please contact Admin.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        return saveMethodPgRef;
    }
    
    public PageReference save(){
        System.debug('Inside save method');
        PageReference pageRef=null;
        String planId=Apexpages.currentPage().getParameters().get('planId');
        String brfId=Apexpages.currentPage().getParameters().get('brfId');
        String pppid=Apexpages.currentPage().getParameters().get('id');
        String parentppid=Apexpages.currentPage().getParameters().get('ppid');
        try{
            
            if(String.isNotBlank(planId) && String.isNotBlank(brfId)){
                if(ppc!=null){
                    if(String.isNotBlank(parentppid)){
                        ppc.Related_Medical_Product__c=parentppid;    
                    } 
                    String errorMessage='';
                    List<Benfit_Request_Form__c> brfList=[select id,Funding_Arrangements__c  from Benfit_Request_Form__c where id=:brfId];
                       //T02 - Start
                    Schema.DescribeSObjectResult d = Schema.SObjectType.Proposed_Products__c; 
                       //T02 - End
                    Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();    
                    Schema.RecordTypeInfo rtById =  rtMapById.get(ppc.RecordTypeId);
                    
                    if(rtById!=null && (rtById.getName()=='Medical' || rtById.getName()=='CareFirst Private Exchange')) {  
                        if((String.isNotBlank(ppc.Funding_Arrangement__c) && ppc.Funding_Arrangement__c=='ASO') || (brfList!=null && brfList.size()>0 && brfList.get(0).Funding_Arrangements__c=='ASO')){
                            if(String.isBlank(ppc.Blue_Rewards__c)){
                                errorMessage='EPP017 : If Funding Arrangements of BRF is "ASO" then Blue Rewards field cannot be blank';
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage);
                                ApexPages.addMessage(myMsg);
                                return null;
                            }
                        }
                    }
                    
               /*     if(rtById!=null && rtById.getName()=='Medical'){ 
                        if((String.isNotBlank(ppc.Funding_Arrangement__c) && ppc.Funding_Arrangement__c=='Risk') || (brfList!=null && brfList.size()>0 && brfList.get(0).Funding_Arrangements__c=='Risk')){
                            if(String.isNotBlank(ppc.Blue_Rewards__c)){
                                errorMessage='EPP234 : If Funding Arrangements on BRF is "Risk" then Blue Rewards field cannot have value';
                                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage);
                                ApexPages.addMessage(myMsg);
                                return null;
                            }
                        } 
                    }     
                    */
                    
                    
                    
                    upsert ppc;
                    pageRef=new PageReference('/'+ppc.id);
                }
                //pageRef.getParameters().put('brfId',brfId);
            }else if(String.isNotBlank(pppid)){
                System.debug('inside else if');
                System.debug('PPC record--->'+ppc);
                List<Proposed_Products__c> proposedProdList=new List<Proposed_Products__c>();
                proposedProdList.add(ppc);
                
                ctler.save();
                pageRef=new PageReference('/'+pppid);
                
            }
        }
        catch(DMLException dmlex) {//T01 Start
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,dmlex.getDmlMessage(0));
            ApexPages.addMessage(myMsg);
            return null;
        }//T01 End
        catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
        }
        return pageRef;
    }
    
    
}