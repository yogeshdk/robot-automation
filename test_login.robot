*** Settings ***

Library     SeleniumLibrary
Library     BuiltIn
Library     String
Library     OperatingSystem
Library     lib/resources.py


*** Variables ***
# ${USERNAME}         venkata@insurance.com

# ${PASSWORD}     Test@12345
${URL}      https://app.insurance.com/login
${Browser}  chrome

${TIME_OUT}     20

*** Keywords ***
Repeat Login and Logout
    [Arguments]    ${no_of_times}

    ${x}=    Set Variable    ${0}
    FOR    ${i}    IN RANGE    ${no_of_times}
        Log In to Portal
        Logout from Insured Portal
    END

Open Browser With Portal Link
    Open Browser    ${URL}  ${Browser}
    Maximize Browser Window
    Wait Until Page Contains     Insurance Portal

Log In to Portal
    [Arguments]       ${user}    ${password}
    Open Browser With Portal Link    
    Input Text      id=email    ${user}
    Input Text      id=password    ${password}
    Click Button    Log In
    Run Keyword And Warn On Failure    Wait Until Page Contains    Security Posture at a glance    timeout=${TIME_OUT}

Logout from Insured Portal
    Go to    ${URL}
      Wait Until Page Contains Element   //*[@data-testid="ExpandMoreIcon"]     timeout=${TIME_OUT}
    Close Browser

Verify dashboard data
    ${str}=    Split String    ${USERNAME}   @
    ${domain}=    Convert To Lowercase    ${str}[1]
    Run Keyword And Warn On Failure    Wait Until Page Contains    ${domain}    timeout=10 
    ${scan_date}=    Get Text    //*[@class='MuiBox-root css-w8l7jg']
    Log To Console    ${scan_date}

Navigate Security Tabs
    ${dns_health}=    Run Keyword And Return Status    Page Should Contain    DNS Health
    Run Keyword If    ${dns_health}   Click Element    //*[contains(text(),'DNS Health')]

    ${data_exposure}=    Run Keyword And Return Status    Page Should Contain    Data Exposure
    Run Keyword If    ${data_exposure}   Click Element    //*[contains(text(),'Data Exposure')]

    ${ssl_security}=    Run Keyword And Return Status    Page Should Contain    SSL Security
    Run Keyword If    ${ssl_security}   Click Element    //*[contains(text(),'SSL Security')]

Download Policy Pdf
    Click Element   //*[contains(text(),'Insurance')]
    Wait Until Page Contains    Your Insurance Policy    
    Click Link  View my Insurance Policy

    Wait Until Created    /home/yogeshk/Downloads/policy.pdf
    ${size}=    Get File Size    /home/yogeshk/Downloads/policy.pdf
    Log To Console    ${size}

    Remove File    /home/yogeshk/Downloads/policy.pdf

Loop on Insured Logins

    ${data}=    Read Input File    test_data/on_board_input.csv
    # Log To Console    ${data}

    FOR  ${item}  IN  @{data}
        Log To Console    ${item}[4]
        Log To Console    ${item}[1]
        Set Global Variable     ${USERNAME}    ${item[4]}
        Set Global Variable     ${PASSWORD}    Test@12345

        Log In to Portal    ${USERNAME}    ${PASSWORD}

        Run Keyword And Warn On Failure	    Verify dashboard data
        Run Keyword And Warn On Failure     Navigate Security Tabs
        Run Keyword And Warn On Failure	    Download Policy Pdf

        Log To Console      ${\n}        
        Logout from Insured Portal

    END

*** Test Cases ***

Verify User Dashboard and Policy Pdf
    Loop on Insured Logins