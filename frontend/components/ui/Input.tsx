import React from "react";

type InputProps = React.ComponentPropsWithoutRef<"input"> & {
  label: string;
};

const Input = React.forwardRef<HTMLInputElement, InputProps>(
  ({ label, ...props }, ref) => {
    return (
      <div>
        <label
          htmlFor={props.id || props.name}
          className="block text-sm font-medium text-gray-200"
        >
          {label}
        </label>
        <div className="mt-1">
          <input
            ref={ref}
            {...props}
            className="block w-full rounded-md border-gray-600 bg-gray-800 text-white shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm p-2"
          />
        </div>
      </div>
    );
  }
);

Input.displayName = "Input";

export { Input };
