function T = load_data(code_commune)
    commune_str = num2str(code_commune);
    % Construct the URL from the commune code
    url = ['https://files.data.gouv.fr/geo-dvf/latest/csv/2024/communes/', ...
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