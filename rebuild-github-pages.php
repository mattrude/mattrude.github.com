<?php
/**
 * Matt's mirror script
 */

/** Required config **
 *********************/

// Your Github login name or organisation name
define( 'GITHUB_LOGIN', 'mattrude' );

// Your Github OAuth token. Refer to the README.
define( 'GITHUB_TOKEN', 'c196cd5f6f7f1217df1744d7b5d5532f4b837784' );


/** Optional config **
 *********************/

define( 'MAX_ATTEMPT', '10' );

/** And run the script **
 ************************/

$api_url = sprintf( 'https://api.github.com/users/%s/repos?per_page=100&access_token=%s', GITHUB_LOGIN, GITHUB_TOKEN );

$success = false;
$attempt = 1;

$json = json_decode( curl_req( 'GET', $api_url, '' ) );
foreach ($json as $name) {

}

// CURL request
function curl_req( $method, $url, $params ) {
    $ch = curl_init();
    curl_setopt( $ch, CURLOPT_URL, $url );
    curl_setopt( $ch, CURLOPT_CUSTOMREQUEST, $method );
    curl_setopt( $ch, CURLOPT_POSTFIELDS, json_encode( $params ) );
    curl_setopt( $ch, CURLOPT_RETURNTRANSFER, true );
    curl_setopt( $ch, CURLOPT_CONNECTTIMEOUT, true );
    curl_setopt( $ch, CURLOPT_SSL_VERIFYPEER, false );
    curl_setopt( $ch, CURLOPT_HEADER, false );
    $content = curl_exec( $ch );
    curl_close( $ch );
    return $content;
}

?>
