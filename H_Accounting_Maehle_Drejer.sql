USE H_Accounting;
DROP PROCEDURE IF EXISTS `cjakobsen2020_pl`;

-- For stored procedure use $$ as delimiter 
DELIMITER $$

-- Create the Profit and Loss table
	CREATE PROCEDURE `cjakobsen2020_pl`(varCalendarYear SMALLINT)
	BEGIN
  
	-- Declare the variables used inside the stored procedures
    DECLARE varRevenue 							DOUBLE DEFAULT 0;
    DECLARE varReturnsRefundsDiscounts 			DOUBLE DEFAULT 0;
    DECLARE varCOGS 							DOUBLE DEFAULT 0;
    DECLARE varGrossProfit 						DOUBLE DEFAULT 0;
	DECLARE varAdminExp 						DOUBLE DEFAULT 0;
    DECLARE varSellingExp						DOUBLE DEFAULT 0;
    DECLARE varOtherExp							DOUBLE DEFAULT 0;
    DECLARE varOtherIncome						DOUBLE DEFAULT 0;
    DECLARE varEBIT								DOUBLE DEFAULT 0;
    DECLARE varIncomeTax						DOUBLE DEFAULT 0;
	DECLARE varOtherTax							DOUBLE DEFAULT 0;
	DECLARE varProfitLoss						DOUBLE DEFAULT 0;

	-- Calculate the different values and store them to the different variables
    
    -- varRevenue
	SELECT SUM(IFNULL(jeli.debit,0) - IFNULL(jeli.credit,0)) INTO varRevenue
            
		FROM journal_entry_line_item AS jeli
			INNER JOIN `account` 			AS ac ON ac.account_id = jeli.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code = 'REV';
            
    -- varReturnsRefundsDiscounts
	SELECT SUM(IFNULL(jeli.debit,0) - IFNULL(jeli.credit,0)) INTO varReturnsRefundsDiscounts
            
		FROM journal_entry_line_item AS jeli
			INNER JOIN `account` 			AS ac ON ac.account_id = jeli.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code = 'RET';       

    -- varCOGS
	SELECT SUM(IFNULL(jeli.debit,0)*-1 + IFNULL(jeli.credit,0)) INTO varCOGS
            
		FROM journal_entry_line_item AS jeli
			INNER JOIN `account` 			AS ac ON ac.account_id = jeli.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code = 'COGS';   

    -- varGrossProfit
	SELECT SUM(IFNULL(jeli.debit,0) - IFNULL(jeli.credit,0)) INTO varGrossProfit
            
		FROM journal_entry_line_item AS jeli
			INNER JOIN `account` 			AS ac ON ac.account_id = jeli.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code IN ('REV', 'RET', 'COGS');
            
	-- varAdminExp
	SELECT SUM(IFNULL(jeli.debit,0)*-1 + IFNULL(jeli.credit,0)) INTO varAdminExp
            
		FROM journal_entry_line_item AS jeli
			INNER JOIN `account` 			AS ac ON ac.account_id = jeli.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code = 'GEXP';

    -- varSellingExp
	SELECT SUM(IFNULL(jeli.debit,0)*-1 + IFNULL(jeli.credit,0)) INTO varSellingExp
            
		FROM journal_entry_line_item AS jeli
			INNER JOIN `account` 			AS ac ON ac.account_id = jeli.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code = 'SEXP'; 
            
	-- varOtherExp
	SELECT SUM(IFNULL(jeli.debit,0)*-1 + IFNULL(jeli.credit,0)) INTO varOtherExp
            
		FROM journal_entry_line_item AS jeli
			INNER JOIN `account` 			AS ac ON ac.account_id = jeli.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code = 'OEXP'; 	   

	-- varOtherIncome
	SELECT SUM(IFNULL(jeli.debit,0) + IFNULL(jeli.credit,0)) INTO varOtherIncome
            
		FROM journal_entry_line_item AS jeli
			INNER JOIN `account` 			AS ac ON ac.account_id = jeli.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code = 'OI';  
             
	-- varEBIT
	SELECT SUM(IFNULL(jeli.debit,0) - IFNULL(jeli.credit,0)) INTO varEBIT
            
		FROM journal_entry_line_item AS jeli
			INNER JOIN `account` 			AS ac ON ac.account_id = jeli.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code IN ('REV','RET', 'COGS','GEXP','SEXP','OEXP','OI');  

	-- varIncomeTax
	SELECT SUM(IFNULL(jeli.debit,0) - IFNULL(jeli.credit,0)) INTO varIncomeTax
            
		FROM journal_entry_line_item AS jeli
			INNER JOIN `account` 			AS ac ON ac.account_id = jeli.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code = 'INCTAX';  
            
	-- varOtherTax
	SELECT SUM(IFNULL(jeli.debit,0) - IFNULL(jeli.credit,0)) INTO varOtherTax
            
		FROM journal_entry_line_item AS jeli
			INNER JOIN `account` 			AS ac ON ac.account_id = jeli.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.profit_loss_section_id <> 0
            AND ss.statement_section_code = 'OTHTAX';  

	-- varProfitLoss
	SELECT SUM(IFNULL(jeli.debit,0) - IFNULL(jeli.credit,0)) INTO varProfitLoss
            
		FROM journal_entry_line_item AS jeli
			INNER JOIN `account` 			AS ac ON ac.account_id = jeli.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.profit_loss_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.profit_loss_section_id <> 0;  

-- Create to show the P&L table with all the right varibales
DROP TABLE IF EXISTS cjakobsen2020_tmp;

	CREATE TABLE cjakobsen2020_tmp
		(	Sl_No INT, 
			Label VARCHAR(50), 
			Amount VARCHAR(50)
		);

	-- Insert the header into the report for a clear understanding
	INSERT INTO cjakobsen2020_tmp 
			(Sl_No, Label, Amount)
			VALUES (1, 'PROFIT AND LOSS STATEMENT', "In USD"),
				   (2, '', ''),
				   (3, 'Revenue', format(varRevenue,0)),
                   (4, 'Returns, Refunds, Discounts', format(IFNULL(varReturnsRefundsDiscounts,0),0)),
                   (5, 'Cost of goods sold', format(varCOGS,0)),
                   (6, 'Gross Profit (Loss)', format(varGrossProfit, 0)),
                   (7, 'Selling Expenses',format(IFNULL(varSellingExp,0),0)),
                   (8, 'Administrative Expenses',format(IFNULL(varAdminExp,0),0)),
                   (9, 'Other Income' , format(IFNULL(varOtherIncome,0),0)),
                   (10, 'Other Expenses', format(IFNULL(varOtherExp,0),0)),
                   (11, 'Earnings before interest and taxes (EBIT)', format(IFNULL(varEBIT,0),0)),
                   (12, 'Income Tax', format(IFNULL(varIncomeTax,0),0)),
                   (13, 'Other Tax', format(IFNULL(varOtherTax,0),0)),
                   (14, 'Profit for the year', format(IFNULL(varProfitLoss,0),0))
;

END $$

DELIMITER ;

-- Call the stored procedures for the profit and loss
CALL cjakobsen2020_pl(2019);

-- use all the data from the tmp
SELECT * FROM cjakobsen2020_tmp;


#---------------------------------------------------------------------------#


-- Create the Balance Sheet table -- 

-- Making sure the data is unique
DROP PROCEDURE IF EXISTS `cjakobsen2020_bs`;
DROP TABLE IF EXISTS cjakobsen2020_tmp;

-- For stored procedure use $$ as delimiter 
DELIMITER $$

-- Create procedure for the calendar year
	CREATE PROCEDURE `cjakobsen2020_bs`(varCalendarYear SMALLINT)
	BEGIN
  
	-- Define the variables inside the stored procedure
    DECLARE vCA 			DOUBLE DEFAULT 0;
    DECLARE vFA 			DOUBLE DEFAULT 0;
    DECLARE vDA 			DOUBLE DEFAULT 0;
    DECLARE vCL				DOUBLE DEFAULT 0;
    DECLARE vLLL 			DOUBLE DEFAULT 0;
    DECLARE vDL 			DOUBLE DEFAULT 0;
    DECLARE vEQ				DOUBLE DEFAULT 0;
    DECLARE vTotalAsset		DOUBLE DEFAULT 0;
    DECLARE vTotalLiabi		DOUBLE DEFAULT 0;
    DECLARE vEquiLiabi		DOUBLE DEFAULT 0;

	-- Calculate the different values and store them to the different variables
    
    -- vCA
	SELECT SUM(IFNULL(joen.debit,0) - IFNULL(joen.credit,0)) INTO vCA
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code = 'CA'
            AND je.debit_credit_balanced = 1;

    -- vFA
	SELECT SUM(IFNULL(joen.debit,0) - IFNULL(joen.credit,0)) INTO vFA
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code = 'FA'
            AND je.debit_credit_balanced = 1;		

	-- vDA
	SELECT SUM(IFNULL(joen.debit,0) - IFNULL(joen.credit,0)) INTO vDA
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code = 'DA'
            AND je.debit_credit_balanced = 1;

    -- vCL
	SELECT SUM(IFNULL(joen.debit,0)*-1 + IFNULL(joen.credit,0)) INTO vCL
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code = 'CL'
            AND je.debit_credit_balanced = 1;	

    -- vLLL
	SELECT SUM(IFNULL(joen.debit,0)*1 + IFNULL(joen.credit,0)) INTO vLLL
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code = 'LLL'
            AND je.debit_credit_balanced = 1;	

    -- vDL
	SELECT SUM(IFNULL(joen.debit,0)*1 + IFNULL(joen.credit,0)) INTO vDL
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code = 'DL'
            AND je.debit_credit_balanced = 1;

    -- vEQ
	SELECT SUM(IFNULL(joen.debit,0)*1 + IFNULL(joen.credit,0)) INTO vEQ
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code = 'EQ'
            AND je.debit_credit_balanced = 1;	

    -- vTotalAsset
	SELECT SUM(IFNULL(joen.debit,0) - IFNULL(joen.credit,0)) INTO vTotalAsset
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code IN ('CA','FA','DA')
            AND je.debit_credit_balanced = 1;	

    -- vTotalLiabi
	SELECT SUM(IFNULL(joen.debit,0)*-1 + IFNULL(joen.credit,0)) INTO vTotalLiabi
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code IN ('CL','LLL','DL')
            AND je.debit_credit_balanced = 1;	
	
        -- vEquiLiabi
	SELECT SUM(IFNULL(joen.debit,0)*-1 + IFNULL(joen.credit,0)) INTO vEquiLiabi
            
		FROM journal_entry_line_item AS joen
			INNER JOIN `account` 			AS ac ON ac.account_id = joen.account_id
			INNER JOIN journal_entry 		AS je ON je.journal_entry_id = joen.journal_entry_id
			INNER JOIN statement_section	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
            
		WHERE YEAR(je.entry_date) = varCalendarYear
			AND ac.balance_sheet_section_id <> 0
            AND ss.statement_section_code NOT IN ('CA','FA','DA')
            AND je.debit_credit_balanced = 1;	
            
    -- Create to show the balance sheet table with all the right varibales
	CREATE TABLE cjakobsen2020_tmp
		(	balance_sheet_line_number INT, 
			label VARCHAR(50), 
			amount VARCHAR(50)
		);
  
	-- Insert the header into the report for a clear understanding
	INSERT INTO cjakobsen2020_tmp 
			(balance_sheet_line_number, label, amount)
			VALUES (1, 'BALANCE SHEET', "In USD"),
				   (2, '', ''),
				   (3, 'Current Assets', format(IFNULL(vCA, 0),0)),
                   (4, 'Fixed Assets', format(IFNULL(vFA, 0),0)),
                   (5, 'Deferred Assets', format(IFNULL(vDA, 0),0)),
                   (6, 'Total Assets', format(IFNULL(vTotalAsset, 0),0)),
                   (7, 'Current Liabilities', format(IFNULL(vCL, 0),0)),
                   (8, 'Long-term Liabilities', format(IFNULL(vLLL, 0),0)),
                   (9, 'Deferred Liabilities' , format(IFNULL(vDL, 0),0)),
                   (10, 'Total Liabilities', format(IFNULL(vTotalLiabi, 0),0)),
                   (11, 'Equity', format(IFNULL(vEQ, 0),0)),
                   (12, 'Total Equity and Liabilities', format(IFNULL(vEquiLiabi, 0),0));
            
  END $$

DELIMITER ;          

-- Call the stored procedures for the B/S
CALL cjakobsen2020_bs(2015);
	
    -- Use all the data from the tmp
SELECT * FROM cjakobsen2020_tmp;  
  
