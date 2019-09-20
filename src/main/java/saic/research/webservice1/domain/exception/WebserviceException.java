package saic.research.webservice1.domain.exception;

public class WebserviceException extends RuntimeException {
	
	private ExceptionType exceptionType;
 
    public WebserviceException(ExceptionType exceptionType, String message, Throwable cause) {
        super(message, cause);
    	this.exceptionType = exceptionType;
    }
    
    public ExceptionType getExceptionType() {
    	return this.exceptionType;
    }
    
    
    public void setExceptionType(ExceptionType exceptionType) {
    	this.exceptionType = exceptionType;
    }
}
