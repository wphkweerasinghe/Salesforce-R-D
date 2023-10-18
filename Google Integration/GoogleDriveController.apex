public without sharing class GoogleDriveController {

    public Static String upload() {
        // Step 1: Get Access Token using Refresh Token
        String accessToken = getAccessToken();
        
        // Step 2: Upload the File to Google Drive
        String link = performMultipartUpload(accessToken);
        return link;
    }
    
    // Method to get Access Token using Refresh Token
    private Static String getAccessToken() {
        String key = '550873756282-3irdeiphd99ldqgvuo5sp440349mu3a6.apps.googleusercontent.com';
        String secret = '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';
        String refreshToken = '1//04IdrBagPqr_ACgYIARAAGAQSNgF-L9IrdTqBWHzEGoF5yTtLUfXLviR2dR2BO7r7dvfFCyYy2fv8dQQlNwEXP0Mn0zxvaljfPA';
        
        String accessToken;
        HttpRequest req2 = new HttpRequest();
        req2.setMethod('POST');
        req2.setEndpoint('https://www.googleapis.com/oauth2/v4/token');
        req2.setHeader('content-type', 'application/x-www-form-urlencoded');
        String messageBody = 'client_id=' + key + '&client_secret=' + secret + '&refresh_token=' + refreshToken + '&grant_type=refresh_token';
        req2.setHeader('Content-length', String.valueOf(messageBody.length()));
        req2.setBody(messageBody);
        req2.setTimeout(60 * 1000);
        Http h2 = new Http();
        HttpResponse res2 = h2.send(req2);
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res2.getBody());
        accessToken = (String) responseMap.get('access_token');
        return accessToken;
    }
    
    // Method to perform multipart upload to Google Drive v3 API and debug the file link
    private Static String performMultipartUpload(String accessToken) {
        String boundary = '----boundary';
        
        String metadataPart = '--' + boundary + '\r\n' +
            'Content-Type: application/json\r\n\r\n' +
            '{"name":"' + RegistrationFormController.fileName + '"}\r\n';
        
        String filePart = '--' + boundary + '\r\n' +
            'Content-Type: application/octet-stream\r\n' +
            'Content-Transfer-Encoding: base64\r\n\r\n' +
            EncodingUtil.base64Encode(RegistrationFormController.fileBody) + '\r\n';
        
        String endBoundary = '\r\n--' + boundary + '--\r\n';
        
        Blob bodyBlob = Blob.valueOf(metadataPart);
        bodyBlob = Blob.valueOf(bodyBlob.toString() + filePart);
        bodyBlob = Blob.valueOf(bodyBlob.toString() + endBoundary);
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'multipart/related; boundary=' + boundary);
        req.setBodyAsBlob(bodyBlob);
        
        Http h = new Http();
        HttpResponse resp = h.send(req);
        
        // Handle the response as needed
        if (resp.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
            String fileId = (String) responseMap.get('id');
            String fileLink = 'https://drive.google.com/uc?id=' + fileId;
            
            System.debug('File uploaded successfully. Google Drive link: ' + fileLink);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'File uploaded successfully. Google Drive link: ' + fileLink));
            return fileLink;
        } else {
            System.debug('Error uploading file. Status code: ' + resp.getStatusCode() + ', Response: ' + resp.getBody());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error uploading file. Status code: ' + resp.getStatusCode()));
            return null;
        }
        
    }    
}