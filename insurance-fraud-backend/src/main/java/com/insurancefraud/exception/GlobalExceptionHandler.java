    package com.insurancefraud.exception;


    import jakarta.servlet.http.HttpServletRequest;
    import org.springframework.http.HttpStatus;
    import org.springframework.http.ResponseEntity;
    import org.springframework.web.bind.annotation.ExceptionHandler;
    import org.springframework.web.bind.annotation.RestControllerAdvice;

    import java.time.LocalDateTime;

    @RestControllerAdvice
    public class GlobalExceptionHandler {


        private ResponseEntity<ApiError> buildErrorResponse(
                HttpStatus status, String error,String message , HttpServletRequest request){

            ApiError apiError = new ApiError(
                    LocalDateTime.now(),
                    status.value(),
                    error,
                    message
                    ,
                    request.getRequestURI()

            );
            return new ResponseEntity<>(apiError,status);
        }

        @ExceptionHandler(UserAlreadyExistsException.class)
        public ResponseEntity<ApiError> handleUserExists(UserAlreadyExistsException ex, HttpServletRequest request) {
            return buildErrorResponse(HttpStatus.CONFLICT, "Conflict", ex.getMessage(), request);
        }

        @ExceptionHandler(TenantNotFoundException.class)
        public ResponseEntity<ApiError> handleTenantNotFound(
                TenantNotFoundException ex,
                HttpServletRequest request
        ) {
            return buildErrorResponse(
                    HttpStatus.NOT_FOUND,
                    "Tenant Not Found",
                    ex.getMessage(),
                    request
            );
        }

        @ExceptionHandler(RoleNotFoundException.class)
        public ResponseEntity<ApiError> handleRoleNotFound(
                RoleNotFoundException ex,
                HttpServletRequest request
        ) {
            return buildErrorResponse(
                    HttpStatus.NOT_FOUND,
                    "Role Not Found",
                    ex.getMessage(),
                    request
            );
        }

        @ExceptionHandler(UserNotFoundException.class)
        public ResponseEntity<ApiError> handleUserNotFound(
                UserNotFoundException ex,
                HttpServletRequest request
        ) {
            return buildErrorResponse(
                    HttpStatus.NOT_FOUND,
                    "User Not Found",
                    ex.getMessage(),
                    request
            );
        }

        @ExceptionHandler(IllegalArgumentException.class)
        public ResponseEntity<ApiError> handleIllegalArgument(
                IllegalArgumentException ex,
                HttpServletRequest request
        ) {
            return buildErrorResponse(
                    HttpStatus.BAD_REQUEST,
                    "Bad Request",
                    ex.getMessage(),
                    request
            );
        }

        @ExceptionHandler(EmailSendFailedException.class)
        public ResponseEntity<ApiError> handleEmailSendFailed(
                EmailSendFailedException ex,
                HttpServletRequest request
        ) {
            return buildErrorResponse(
                    HttpStatus.INTERNAL_SERVER_ERROR,
                    "Email Error",
                    ex.getMessage(),
                    request
            );
        }


















        @ExceptionHandler(Exception.class)
        public ResponseEntity<ApiError> handleGlobalException(
                Exception ex,
                HttpServletRequest request
        ) {
            return buildErrorResponse(
                    HttpStatus.INTERNAL_SERVER_ERROR,
                    "Internal Server Error",
                    ex.getMessage(),
                    request
            );
        }
    }
