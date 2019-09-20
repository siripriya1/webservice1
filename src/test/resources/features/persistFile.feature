Feature: Persist XML
  Scenario: client makes call to GET /persistFile with existing Transaction T0018 xml file
    When the client calls /persistFile with existing Transaction T0018 xmlfile name
		Then the client receives a response status code of 200
		And the client recieves the persistResponse as expected

	Scenario: client makes call to GET /persistFile with already processed Transaction T0018 xmlfile
    When the client calls /persistFile with  already processed Transaction T0018 xml file name
		Then the client receives a response status code of 409
		And the client recieves the unique constraint violation ErrorResponse as expected	
		
	Scenario: client makes call to GET /persistFile with nonexisting xmlfile
    When the client calls /persistFile with non-existing file name
		Then the client receives a response status code of 404
		And the client recieves the file not found ErrorResponse as expected	
		
		
		
		