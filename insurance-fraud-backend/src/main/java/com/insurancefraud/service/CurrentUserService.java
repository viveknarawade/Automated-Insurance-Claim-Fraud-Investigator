package com.insurancefraud.service;

import com.insurancefraud.entity.User;

public interface CurrentUserService {

    User getCurrentUser();

    User getCurrentActiveUser();
}