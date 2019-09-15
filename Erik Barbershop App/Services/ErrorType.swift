//
//  ErrorType.swift
//  Erik Barbershop App
//
//  Created by Brian on 4/6/19.
//  Copyright © 2019 Brian. All rights reserved.
//

import Foundation

///This is the enum for the error description if something goes wrong processing somebody's payment.
enum paymentError {
    case UhOh
    case tooLate
    case refundError
}

extension paymentError: LocalizedError {
    ///Payment error description.
    public var errorDescription: String? {
        switch self {
        case .UhOh:
            return NSLocalizedString("Something went wrong while processing your payment, please try again.", comment: "Payment Processing Error")
            
        case .tooLate:
            return NSLocalizedString("The date of this appointment has already passed, please choose another date.(Your money has been refunded)", comment: "Appointment already passed.")
            
        case .refundError:
            return NSLocalizedString("An error occured while processing your refund, please contact brian6549@hotmail.com to resolve the issue.", comment: "Refund Error")
        }
    }
}


