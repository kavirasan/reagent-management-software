import React from "react";
import { cva } from "class-variance-authority";
import { cn } from "@/lib/utils";

const buttonVariants = cva(
  "inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-400 disabled:pointer-events-none disabled:opacity-50 h-10 px-4 py-2",
  {
    variants: {
      variant: {
        default: "bg-slate-900 text-white hover:bg-slate-700",
        outline: "border border-slate-300 bg-white text-slate-900 hover:bg-slate-100"
      }
    },
    defaultVariants: {
      variant: "default"
    }
  }
);

const Button = React.forwardRef(({ className, variant, ...props }, ref) => {
  return <button className={cn(buttonVariants({ variant }), className)} ref={ref} {...props} />;
});

Button.displayName = "Button";

export { Button, buttonVariants };
