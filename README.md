# immo

[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=yanndebray/immo&file=immo.mlx)

🏠 Real Estate prices in French cities


Inspiration: [https://github.com/slevin48/immo](https://github.com/slevin48/immo)


Data source: [https://www.data.gouv.fr/fr/datasets/5cc1b94a634f4165e96436c1/](https://www.data.gouv.fr/fr/datasets/5cc1b94a634f4165e96436c1/) 


Example in Paris (14th arrondissement)

```matlab
commune = "75114";
price_min = 7500;
price_max = 12000;
date_start = datetime("2023-03-14", "InputFormat", "uuuu-MM-dd");

T = load_data(commune);
T = T(T.prixm2 > price_min & T.prixm2 < price_max & T.date_mutation > date_start,{'id_mutation','date_mutation','valeur_fonciere','prixm2','adresse_numero','adresse_nom_voie','latitude','longitude','marker_color'})
```
| |id_mutation|date_mutation|valeur_fonciere|prixm2|adresse_numero|adresse_nom_voie|latitude|longitude|marker_color|
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
|1|'2023-563047'|30-Jun-2023|490800|10016|3|'RUE FURTADO HEINE'|48.8301|2.3196|'red'|
|2|'2023-563211'|30-Jun-2023|1275000|11486|21|'VLA D ALESIA'|48.8279|2.3242|'red'|
|3|'2023-563217'|30-Jun-2023|615000|10789|8|'RUE FURTADO HEINE'|48.8300|2.3190|'red'|
|4|'2023-563251'|30-Jun-2023|108000|9818|17|'RUE MORERE'|48.8246|2.3216|'yellow'|
|5|'2023-563372'|30-Jun-2023|112000|8615|19|'RUE DU COUEDIC'|48.8301|2.3326|'yellow'|
|6|'2023-563583'|30-Jun-2023|490000|8167|68|'RUE DE GERGOVIE'|48.8322|2.3168|'yellow'|
|7|'2023-563740'|30-Jun-2023|220000|11579|3|'RUE DE CHATILLON'|48.8272|2.3237|'red'|
|8|'2023-564028'|30-Jun-2023|500000|9804|49|'RUE SARRETTE'|48.8252|2.3275|'yellow'|
|9|'2023-564031'|30-Jun-2023|540000|9474|17|'RUE BEAUNIER'|48.8240|2.3299|'yellow'|
|10|'2023-564044'|30-Jun-2023|605000|9758|41|'RUE JONQUOY'|48.8292|2.3162|'yellow'|
|11|'2023-564045'|30-Jun-2023|750000|8929|84|'RUE DIDOT'|48.8288|2.3161|'yellow'|
|12|'2023-563042'|29-Jun-2023|149660|8314|98|'RUE RAYMOND LOSSERAND'|48.8330|2.3157|'yellow'|
|13|'2023-563203'|29-Jun-2023|162000|7714|26|'RUE BREZIN'|48.8315|2.3275|'yellow'|
|14|'2023-563288'|29-Jun-2023|240000|10435|133|'RUE RAYMOND LOSSERAND'|48.8319|2.3147|'red'|

```matlab
s = geoscatter(T,"latitude","longitude","filled");
s.ColorVariable = "prixm2";
c = colorbar;
c.Label.String = "Price (€) per square meter";
```

![figure_0.png](README_media/figure_0.png)

```matlab
histogram(T.prixm2)
```

![figure_1.png](README_media/figure_1.png)

```matlab
function T = load_data(code_commune)
    commune_str = num2str(code_commune);
    % Construct the URL from the commune code
    url = ['https://files.data.gouv.fr/geo-dvf/latest/csv/2023/communes/', ...
           commune_str(1:2) '/', commune_str, '.csv'];
       
    % Read the CSV data from the URL
    opts = detectImportOptions(url, 'DatetimeType', 'text'); % Adjust import options if necessary
    T = readtable(url, opts);
    
    % Convert date_mutation to datetime
    T.date_mutation = datetime(T.date_mutation, 'InputFormat', 'yyyy-MM-dd');
    
    % Drop rows with missing values in specified columns
    T = rmmissing(T, 'DataVariables', {'valeur_fonciere', 'surface_reelle_bati', 'longitude', 'latitude'});
    
    % Calculate price per m2 and filter
    T.prixm2 = T.valeur_fonciere ./ T.surface_reelle_bati;
    T = T(T.prixm2 > 1000 & T.prixm2 < 15000, :);
    
    % Convert prixm2 to integer
    T.prixm2 = int32(T.prixm2);
    
    % Assign marker colors based on prixm2 value
    edges = [0, 2500, 5000, 10000, 15000]; % Adjust bins as needed
    [~, ~, bins] = histcounts(T.prixm2, edges);
    colors = {'blue', 'green', 'yellow', 'red'};
    T.marker_color = colors(bins)';
    
    % Sort by date_mutation
    T = sortrows(T, 'date_mutation', 'descend');
end

% % Example usage:
% commune = 75114;
% T = load_data(commune)
```
