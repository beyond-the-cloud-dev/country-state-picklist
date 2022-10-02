public with sharing class AddressSelectorMetadataApi {
    public static Map<String, List<Object>> getAddressSettings() {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        service.CallOptions = new MetadataService.CallOptions_element();
        service.timeout_x = 120000;

        List<MetadataService.AddressSettings> ans = new List<MetadataService.AddressSettings>();

        ans.addAll((List<MetadataService.AddressSettings>) service.readMetadata('AddressSettings', new List<String>{
                'Address'
        }).getRecords());

        MetadataService.AddressSettings addressSettings = ans[0];

        List<Country> countires = new List<Country>();
        List<State> states = new List<State>();

        for (MetadataService.Country country : addressSettings.countriesAndStates.countries) {

            countires.add(new Country(country.label, country.isoCode));

            if (country.states == null) {
                continue;
            }

            for (MetadataService.State state : country.states) {
                states.add(new State(state.label, state.isoCode, country.isoCode));
            }
        }

        return new Map<String, List<Object>>{
            'countries' => countires,
            'states' => states
        };
    }
}
