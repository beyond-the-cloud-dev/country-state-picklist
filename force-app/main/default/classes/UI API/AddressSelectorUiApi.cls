public with sharing class AddressSelectorUiApi {

    public static Map<String, List<Object>> getAddressSettings() {
        return new Map<String, List<Object>>{
            'countries' => getCountries(),
            'states' => getStates()
        };
    }

    public static List<Country> getCountries() {
        Map<String, Object> uiApiResponse = (Map<String, Object>) JSON.deserializeUntyped(
            AddressSelectorUiApi.callSalesforceUiApi('/services/data/v54.0/ui-api/object-info/Account/picklist-values/012000000000000AAA/BillingCountryCode')
        );

        List<Country> countries = new List<Country>();

        for (Object countryObject : (List<Object>) uiApiResponse.get('values')) {
            Map<String, Object> country = (Map<String, Object>) countryObject;

            countries.add(new Country((String) country.get('label'), (String) country.get('value')));
        }

        return countries;
    }

    public static List<State> getStates() {
        Map<String, Object> uiApiResponse = (Map<String, Object>) JSON.deserializeUntyped(
            AddressSelectorUiApi.callSalesforceUiApi('/services/data/v54.0/ui-api/object-info/Account/picklist-values/012000000000000AAA/BillingStateCode')
        );

        Map<String, Object> countryToValidFor = (Map<String, Object>) uiApiResponse.get('controllerValues');

        Map<Integer, String> validForToCountry = new Map<Integer, String>();

        for (String countryIsoCode : countryToValidFor.keySet()) {
            validForToCountry.put((Integer) countryToValidFor.get(countryIsoCode), countryIsoCode);
        }

        List<State> states = new List<State>();

        for (Object stateObject : (List<Object>) uiApiResponse.get('values')) {
            Map<String, Object> state = (Map<String, Object>) stateObject;
            List<Object> validFor = (List<Object>) state.get('validFor');

            states.add(
                new State(
                    (String) state.get('label'),
                    (String) state.get('value'),
                    (String) (validFor.isEmpty() ? '' : validForToCountry.get((Integer) validFor[0]))
                )
            );
        }

        return states;
    }

    public static String callSalesforceUiApi(String endpoint) {
        String restApiUrl = URL.getOrgDomainUrl().toExternalForm() + endpoint;

        HttpRequest request = new HttpRequest();
        request.setEndpoint(restApiUrl);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());

        HttpResponse response = new Http().send(request);

        if (response.getStatusCode() == 200) {
            return response.getBody();
        }

        return '';
    }
}
